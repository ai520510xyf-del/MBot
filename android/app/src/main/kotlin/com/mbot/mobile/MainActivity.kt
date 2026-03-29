package com.mbot.mobile

import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.BufferedReader
import java.io.File
import java.io.InputStreamReader
import java.util.concurrent.TimeUnit

class MainActivity : FlutterActivity() {
    private val TAG = "MBotNode"
    private val CHANNEL = "com.mbot.mobile/nodejs"

    private var nodeProcess: Process? = null
    private var nodeThread: Thread? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getNodeBinaryPath" -> {
                    result.success(resolveNodeBinary())
                }
                "startNodeProcess" -> {
                    @Suppress("UNCHECKED_CAST")
                    val args = call.argument<List<String>>("args") ?: emptyList()
                    @Suppress("UNCHECKED_CAST")
                    val env = call.argument<Map<String, String>>("env") ?: emptyMap()
                    val workDir = call.argument<String>("workDir") ?: filesDir.absolutePath
                    try {
                        val pid = startNode(args, env, workDir)
                        result.success(pid)
                    } catch (e: Exception) {
                        result.error("START_FAILED", e.message, null)
                    }
                }
                "stopNodeProcess" -> {
                    stopNode()
                    result.success(null)
                }
                "isNodeRunning" -> {
                    result.success(isNodeAlive())
                }
                else -> result.notImplemented()
            }
        }
    }

    /// 解析 Node.js 可执行路径
    ///
    /// nodejs-mobile 的 libnode.so 同时就是可执行文件，
    /// Android 的 linker 可以直接执行 .so 文件。
    private fun resolveNodeBinary(): String? {
        val abi = getAbi()

        // 搜索路径：App native lib 目录
        val searchPaths = listOf(
            applicationInfo.nativeLibraryDir,  // /data/data/.../lib/arm64
        )

        for (base in searchPaths) {
            val nodeFile = File(base, "libnode.so")
            if (nodeFile.exists()) {
                Log.i(TAG, "Found libnode.so at: ${nodeFile.absolutePath}")
                return nodeFile.absolutePath
            }
        }

        Log.e(TAG, "libnode.so not found. ABI=$abi, paths=$searchPaths")
        return null
    }

    /// 获取当前 ABI
    private fun getAbi(): String {
        return try {
            Build.SUPPORTED_ABIS[0]
        } catch (e: Exception) {
            "arm64-v8a"
        }
    }

    /// 启动 Node.js 进程
    private fun startNode(
        args: List<String>,
        env: Map<String, String>,
        workDir: String
    ): Long {
        val nodePath = resolveNodeBinary()
            ?: throw RuntimeException("libnode.so not found")

        val cmd = mutableListOf(nodePath)
        cmd.addAll(args)

        Log.i(TAG, "Starting: ${cmd.take(3).joinToString(" ")}${if (cmd.size > 3) " ..." else ""}")
        Log.i(TAG, "Work dir: $workDir")

        val pb = ProcessBuilder(cmd)
        pb.directory(File(workDir))
        pb.redirectErrorStream(false)

        // 设置环境变量
        val procEnv = pb.environment()
        procEnv.clear()
        procEnv.putAll(System.getenv())
        // 确保动态链接器能找到库
        procEnv["LD_LIBRARY_PATH"] = "${applicationInfo.nativeLibraryDir}:${procEnv.getOrDefault("LD_LIBRARY_PATH", "")}"
        // 合并调用方传入的环境变量
        procEnv.putAll(env)

        nodeProcess = pb.start()

        // 后台线程读取 stdout
        nodeThread = Thread {
            try {
                BufferedReader(InputStreamReader(nodeProcess!!.inputStream)).use { reader ->
                    reader.forEachLine { line ->
                        Log.d(TAG, "[node] $line")
                    }
                }
            } catch (e: Exception) {
                // 进程结束时可能抛异常，忽略
            }
        }
        nodeThread?.name = "node-stdout-reader"
        nodeThread?.isDaemon = true
        nodeThread?.start()

        // 后台线程读取 stderr
        Thread {
            try {
                BufferedReader(InputStreamReader(nodeProcess!!.errorStream)).use { reader ->
                    reader.forEachLine { line ->
                        Log.w(TAG, "[node:err] $line")
                    }
                }
            } catch (_: Exception) {}
        }.apply {
            name = "node-stderr-reader"
            isDaemon = true
            start()
        }

        return nodeProcess!!.pid().toLong()
    }

    /// 停止 Node.js 进程
    private fun stopNode() {
        val proc = nodeProcess ?: return
        Log.i(TAG, "Stopping node (pid=${proc.pid()})")
        proc.destroy()
        try {
            if (!proc.waitFor(5, TimeUnit.SECONDS)) {
                proc.destroyForcibly()
                Log.w(TAG, "Node killed forcibly")
            }
        } catch (e: Exception) {
            Log.w(TAG, "Error stopping node: ${e.message}")
        }
        nodeProcess = null
    }

    /// 检查 Node.js 是否存活
    private fun isNodeAlive(): Boolean {
        val proc = nodeProcess ?: return false
        return try {
            proc.pid() > 0 && proc.isAlive
        } catch (e: Exception) {
            false
        }
    }

    override fun onDestroy() {
        stopNode()
        super.onDestroy()
    }
}

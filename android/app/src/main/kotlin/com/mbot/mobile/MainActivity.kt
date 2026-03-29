package com.mbot.mobile

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
    private fun resolveNodeBinary(): String {
        val searchPaths = listOf(
            applicationInfo.nativeLibraryDir,
        )

        for (base in searchPaths) {
            val nodeFile = File(base, "libnode.so")
            if (nodeFile.exists()) {
                Log.i(TAG, "Found libnode.so at: ${nodeFile.absolutePath}")
                return nodeFile.absolutePath
            }
        }

        Log.e(TAG, "libnode.so not found")
        error("libnode.so not found")
    }

    /// 启动 Node.js 进程
    private fun startNode(
        args: List<String>,
        env: Map<String, String>,
        workDir: String
    ): Long {
        val nodePath = resolveNodeBinary()

        val cmd = mutableListOf(nodePath)
        cmd.addAll(args)

        Log.i(TAG, "Starting Node.js: ${cmd.take(3).joinToString(" ")}${if (cmd.size > 3) " ..." else ""}")
        Log.i(TAG, "Work dir: $workDir")

        val pb = ProcessBuilder(cmd)
        pb.directory(File(workDir))
        pb.redirectErrorStream(false)

        val procEnv = pb.environment()
        procEnv.clear()
        procEnv.putAll(System.getenv())
        procEnv["LD_LIBRARY_PATH"] = "${applicationInfo.nativeLibraryDir}:${procEnv.getOrDefault("LD_LIBRARY_PATH", "")}"
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
            } catch (_: Exception) {}
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

        // 获取 PID
        val pid = try {
            val field = Process::class.java.getDeclaredMethod("pid")
            field.invoke(nodeProcess) as Int
        } catch (e: Exception) { -1 }
        return pid.toLong()
    }

    /// 停止 Node.js 进程
    private fun stopNode() {
        val proc = nodeProcess ?: return
        val pid = try {
            val field = Process::class.java.getDeclaredMethod("pid")
            field.invoke(proc) as Int
        } catch (e: Exception) { 0 }
        Log.i(TAG, "Stopping node (pid=$pid)")
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
            proc.alive
        } catch (e: Exception) {
            try { proc.exitValue() } catch (_: Exception) {}
            false
        }
    }

    override fun onDestroy() {
        stopNode()
        super.onDestroy()
    }
}

package com.mbot.mobile

import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.BufferedReader
import java.io.File
import java.io.InputStreamReader

class MainActivity : FlutterActivity() {
    private val TAG = "MBotNode"
    private val CHANNEL = "com.mbot.mobile/nodejs"
    private var nodeProcess: Process? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getNodeBinaryPath" -> result.success(findNodeBinary())
                "startNodeProcess" -> {
                    @Suppress("UNCHECKED_CAST")
                    val args = call.argument<List<String>>("args") ?: emptyList()
                    @Suppress("UNCHECKED_CAST")
                    val env = call.argument<Map<String, String>>("env") ?: emptyMap()
                    val workDir = call.argument<String>("workDir") ?: filesDir.absolutePath
                    try { result.success(startNode(args, env, workDir)) }
                    catch (e: Exception) { result.error("START_FAILED", e.message, null) }
                }
                "stopNodeProcess" -> { stopNode(); result.success(null) }
                "isNodeRunning" -> result.success(nodeProcess != null)
                else -> result.notImplemented()
            }
        }
    }

    private fun findNodeBinary(): String {
        val dir = applicationInfo.nativeLibraryDir
        val f = File(dir, "libnode.so")
        if (f.exists()) return f.absolutePath
        error("libnode.so not found at $dir")
    }

    private fun startNode(args: List<String>, env: Map<String, String>, workDir: String): Long {
        val cmd = mutableListOf(findNodeBinary())
        cmd.addAll(args)
        Log.i(TAG, "Starting: ${cmd.take(2).joinToString(" ")} ...")

        val pb = ProcessBuilder(cmd)
        pb.directory(File(workDir))
        pb.redirectErrorStream(false)
        val pe = pb.environment()
        pe.clear()
        pe.putAll(System.getenv())
        pe["LD_LIBRARY_PATH"] = applicationInfo.nativeLibraryDir
        pe.putAll(env)

        nodeProcess = pb.start()
        Thread { nodeProcess!!.inputStream.bufferedReader().forEachLine { Log.d(TAG, "[node] $it") } }.start()
        Thread { nodeProcess!!.errorStream.bufferedReader().forEachLine { Log.w(TAG, "[node:err] $it") } }.start()
        return 1L
    }

    private fun stopNode() {
        nodeProcess?.destroy()
        nodeProcess = null
    }

    override fun onDestroy() { stopNode(); super.onDestroy() }
}

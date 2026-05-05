package dev.picon.mobile.sslpinning.android.network

import okhttp3.OkHttpClient
import okhttp3.Request

class PlatformPinnedHttpClient : BackendClient{
    override val clientName: String = "Android Network Security Config"

    private val client = OkHttpClient.Builder()
        .build()

    override fun callHealth(): String {
        val request = Request.Builder()
            .url("https://10.0.2.2:8443/health")
            .build()

        client.newCall(request).execute().use { response ->
            if (!response.isSuccessful) {
                error("Unexpected response: ${response.code}")
            }

            return response.body?.string().orEmpty()
        }
    }
}
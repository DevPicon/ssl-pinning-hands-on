package dev.picon.mobile.sslpinning.android.network

import okhttp3.CertificatePinner
import okhttp3.OkHttpClient
import okhttp3.Request


class PinnedHttpClient(
    sslPin: String
) {

    private val certificatePinner = CertificatePinner.Builder()
        .add(
            "10.0.2.2",
            sslPin
        )
        .build()

    private val client = OkHttpClient.Builder()
        .certificatePinner(certificatePinner)
        .build()

    fun callHealth(): String {
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
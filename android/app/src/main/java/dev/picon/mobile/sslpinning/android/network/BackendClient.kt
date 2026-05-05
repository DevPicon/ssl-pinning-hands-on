package dev.picon.mobile.sslpinning.android.network

interface BackendClient {
    val clientName: String
    fun callHealth(): String
}
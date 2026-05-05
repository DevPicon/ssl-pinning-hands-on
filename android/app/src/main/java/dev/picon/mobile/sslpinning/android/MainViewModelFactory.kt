package dev.picon.mobile.sslpinning.android

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import dev.picon.mobile.sslpinning.android.network.BackendClient
import dev.picon.mobile.sslpinning.android.network.PinnedHttpClient
import dev.picon.mobile.sslpinning.android.network.PlatformPinnedHttpClient

class MainViewModelFactory(
    private val sslPin: String,
    private val useOkHttpPinning: Boolean
) : ViewModelProvider.Factory {

    @Suppress("UNCHECKED_CAST")
    override fun <T : ViewModel> create(modelClass: Class<T>): T {
        val client: BackendClient = if (useOkHttpPinning) {
            PinnedHttpClient(sslPin = sslPin)
        } else {
            PlatformPinnedHttpClient()
        }

        return MainViewModel(client) as T
    }
}
package dev.picon.mobile.sslpinning.android

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import dev.picon.mobile.sslpinning.android.network.PinnedHttpClient

class MainViewModelFactory(
    private val sslPin: String
) : ViewModelProvider.Factory {

    @Suppress("UNCHECKED_CAST")
    override fun <T : ViewModel> create(modelClass: Class<T>): T {
        val client = PinnedHttpClient(sslPin = sslPin)
        return MainViewModel(client) as T
    }
}
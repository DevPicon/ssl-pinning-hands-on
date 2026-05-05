package dev.picon.mobile.sslpinning.android

import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import dev.picon.mobile.sslpinning.android.network.PinnedHttpClient
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

class MainViewModel(
    private val httpClient: PinnedHttpClient
) : ViewModel() {

    var uiState by mutableStateOf(MainUiState())
        private set

    fun callBackend() {
        viewModelScope.launch {
            uiState = uiState.copy(isLoading = true, message = "Loading...")

            uiState = try {
                val response = withContext(Dispatchers.IO) {
                    httpClient.callHealth()
                }

                MainUiState(message = response)
            } catch (e: Exception) {
                MainUiState(message = "Error: ${e.message}")
            }
        }
    }
}
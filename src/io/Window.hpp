#pragma once

#include "core/defines.hpp"
#include "sx/math.h"

struct GLFWwindow;

namespace ari
{
	namespace io
	{
		static const int MaxWindow = 16;

		ARI_HANDLE(WindowHandle);

		static const WindowHandle MainWindow = { 0, 0 };
		
		struct Window
		{
			int Width = 640;
			int Height = 480;
			bool FullScreen = false;
			bool HighDpi = false;
			float DpiScale = 1.0f;
		};        

		WindowHandle CreateAriWindow(Window& window, const char* _title);

		GLFWwindow* GetGlfwWindow(const WindowHandle& handle);

        /**
         * @brief Run the windows and handle the events.
         * 
         * Need to call it every frame.
         * 
         * @return true when the application wants to continue
         * @return false when the user request to close the application
         */
		bool Run();

		sx_rect GetWindowSize(const WindowHandle& handle);

		const void* AndroidGetNativeActivity();

	} // namespace io
	
} // namespace ari

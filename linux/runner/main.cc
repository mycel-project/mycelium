#include "my_application.h"
#include <X11/Xlib.h>
#include <stdlib.h>

int main(int argc, char** argv) {
  XInitThreads();
  // Force SHM buffers from WPE (avoids DMA-BUF/EGL path that causes freezes
  // and rendering issues on some Linux graphics drivers)
  setenv("LIBGL_ALWAYS_SOFTWARE", "1", 1);
  setenv("FLUTTER_INAPPWEBVIEW_LINUX_DISABLE_GL", "1", 1);
  g_autoptr(MyApplication) app = my_application_new();
  return g_application_run(G_APPLICATION(app), argc, argv);
}

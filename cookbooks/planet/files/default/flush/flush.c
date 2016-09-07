#include <dlfcn.h>
#include <unistd.h>

static int (*real_close)(int fd);

static void __attribute__((constructor)) initialise(void)
{
  real_close = dlsym(RTLD_NEXT, "close");
}

int close(int fd)
{
  fdatasync(fd);

  return real_close(fd);
}

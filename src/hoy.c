/**
* HOY
*
*   Crea carpeta con la fecha actual
*
*   - multiplataforma
*   @NicRiv
*/
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <sys/stat.h>
#include <time.h>

#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <time.h>

/* --- Encabezados y macro portátil para mkdir --- */
#ifdef _WIN32
    #include <direct.h>
    #define portable_mkdir(path, mode) _mkdir(path)
#else
    #include <sys/stat.h>
    #define portable_mkdir(path, mode) mkdir((path), (mode))
#endif

int main(void)
{
    char dir[16];
    time_t t = time(NULL);
    struct tm *ltm = localtime(&t);

    if (ltm == NULL) {
        perror("localtime");
        return 1;
    }

    if (strftime(dir, sizeof dir, "%d%m%y", ltm) == 0) {
        fprintf(stderr, "strftime: buffer demasiado pequeño\n");
        return 1;
    }

    if (portable_mkdir(dir, 0755) == -1) {
        if (errno == EEXIST) {
            fprintf(stderr, "La carpeta %s ya existía\n", dir);
        } else {
            perror("mkdir");
            return 1;
        }
    } else {
        fprintf(stderr, "carpeta creada: %s\n", dir);
    }

    puts(dir);
    return 0;
}
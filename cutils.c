#include <stdio.h>

#ifdef DEBUG
void Log(const char* tolog) {
        FILE* ptr = fopen("/var/mobile/hsNasaLog.log", "a+");
        fputs(tolog, ptr);
        fclose(ptr);
}
#else
void Log(const char* tolog) {
	return;
}
#endif


#include <stdio.h>
#include <sys/time.h>

int main()
{
    struct timeval time_now;
    gettimeofday(&time_now,NULL);
    printf("%lf\n", (double)time_now.tv_sec + (double)time_now.tv_usec/1000000);

    return 0;
}
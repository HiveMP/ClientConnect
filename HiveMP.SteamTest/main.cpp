#include "connect.hpp"
#include <stdio.h>

int main()
{
    printf("test started\n");

    printf("loading Lua code\n");
    cc_load("print(\"test\");");

    printf("checking if hotpatched\n");
    if (cc_is_hotpatched("admin-session", "sessionPUT"))
    {
        int statusCode;
        const char* result = cc_call_hotpatch("admin-session", "sessionPUT", "", "{\"username\": \"test\", \"password\": \"test\"}", &statusCode);
        printf("%i - %s\n", statusCode, result);
    }
    else
    {
        printf("admin-session sessionPUT is not hotpatched!\n");
    }

    return 0;
}
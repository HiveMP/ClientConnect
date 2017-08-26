#include "connect.hpp"
#include <stdio.h>
#include <fstream>
#include <sstream>

int main()
{
	std::ostringstream sstream;
	std::ifstream fs("test.lua");
	sstream << fs.rdbuf();
	const std::string str(sstream.str());
	const char* ptr = str.c_str();

    cc_load(ptr, "file:test.lua");

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
#include <iostream>

using namespace std;

const char* read(const char* cstr_input)
{
    return cstr_input;
}

const char* eval(const char* cstr_parsed)
{
    return cstr_parsed;
}

const char* print(const char* cstr_evaluated)
{
    return cstr_evaluated;
}

const char* rep(const char* input)
{
    const char* parsed = read(input);
    const char* evaluated = eval(parsed);

    return print(evaluated);
}

int main()
{
    char input[MAX_INPUT];
    const char* result = nullptr;
    memset(input, 0, MAX_INPUT);

    cout << "user> ";
    cin.getline(input, MAX_INPUT);
    while (!cin.eof() && !cin.fail()) {
        result = rep(input);
        cout << result << endl;

        cout << "user> ";
        cin.getline(input, MAX_INPUT);
    }
    
    return 0;
}

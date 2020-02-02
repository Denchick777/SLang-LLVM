#include "command_line_args.hpp"

using namespace SLang::CodeGenerator;

using namespace std;

optional<CommandLineArgs> CommandLineArgs::Parse(const vector<string_view> &args) noexcept
{
    CommandLineArgs result;

    if (args.size() < 2)
    {
        return nullopt;
    }

    // TODO: add support for help info flag.

    // TODO: use constructor of `std::filesystem::path` with C++20 (`u8path` will be deprecated).
    result.in_path_ = filesystem::u8path(args[1]).lexically_normal();

    (result.out_path_ = result.InputPath()).replace_extension(u8".obj");

    return result;
}

If you'd like to contribue to this project, there are several different methods:

- Submit a [Pull Request](https://www.github.com/pcgeek86/PSGitHub/pulls) against the GitHub repository, containing:
  - Bug fixes
  - Documentation enhancements
  - Continuous integration & deployment enhancements
- Perform user testing and validation, and report bugs on the [Issue Tracker](https://www.github.com/pcgeek86/PSGitHub/issues)
- Raise awareness about the project through [Twitter](https://twitter.com/#PowerShell), [Facebook](https://facebook.com), and other social media platforms

If you're new to Git revision control, and the GitHub service, it's suggested that you learn about some basic Git fundamentals, and take an overview of the GitHub service offerings.

# Contribution Guidelines

Different software developers have different styles. If you're interested in contributing to this project, please review the following guidelines. 
While these guidelines aren't necessarily "set in stone," they should help guide the essence of the project, to ensure quality, user satisfaction (*delight*, even), and success.

## Project Structure

- The module manifest (`.psd1` file) must explicitly denote which functions are being exported. No wildcards allowed.
- Private, helper functions should exist under `/Functions/Private`.
- Publicly accessible functions should exist under `/Functions/Public`.
  - We may create subfolders for categories, if this gets too uncontrollable.
- Only one function can be defined in each script file, for public-facing functions.
- Use comment-based help inside the function definition, before the `[CmdletBinding()]` attribute and parameter block
- All functions must declare the `[CmdletBinding()]` attribute.
- Any module configuration, or cached data (such as authentication tokens), should be stored under a single JSON file.
- No use of XML anywhere in the project, unless you enjoy doing work that won't get merged.

## Testing 

- We will use the Pester testing framework to perform unit tests.
- Test files should be broken into GitHub feature areas (eg. Repositories, Issues, Users, etc.).
- Test files should exist under `/Tests`.


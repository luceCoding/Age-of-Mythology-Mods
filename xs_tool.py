import os
import re
import textwrap

def process_xs_template(folder_path, template_filename="template.xs", output_filename="output.xs", output_path=None):
    template_path = os.path.join(folder_path, template_filename)

    if not os.path.exists(template_path):
        print(f"Error: Could not find {template_path}")
        return

    # UPDATED: Included / and \ to support subfolder paths like "common/ui.xs"
    comment_pattern = re.compile(r'^(\s*)//\s*([a-zA-Z0-9_/\.-]+\.xs).*$')
    
    # Matches lines like: include "ui.xs"; or #include "ui.xs";
    include_statement_pattern = re.compile(r'^\s*#?\s*include\s+["<][^">]+[">]\s*;?\s*$')

    output_lines = []

    with open(template_path, 'r', encoding='utf-8') as f:
        template_lines = f.readlines()

    MAX_LENGTH = 80

    for line_num, line in enumerate(template_lines):
        match = comment_pattern.match(line)
        
        if match:
            # Normalize slashes for operating system compatibility
            include_filename = os.path.normpath(match.group(2))
            include_path = os.path.join(folder_path, include_filename)

            if os.path.exists(include_path):
                print(f"Injecting {include_filename}...")
                with open(include_path, 'r', encoding='utf-8') as inc_file:
                    for inner_line in inc_file:
                        inner_line = inner_line.rstrip('\r\n')
                        stripped_content = inner_line.lstrip()

                        # Skip line if it's an include statement
                        if include_statement_pattern.match(stripped_content):
                            continue

                        # Escape double quotes
                        escaped_content = stripped_content.replace('"', '\\"')
                        
                        if len(escaped_content):
                            if len(escaped_content) > MAX_LENGTH:
                                chunks = textwrap.wrap(
                                    escaped_content,
                                    width=MAX_LENGTH,
                                    break_long_words=True,
                                    replace_whitespace=False
                                )
                            else:
                                chunks = [escaped_content]

                            for chunk in chunks:
                                wrapped_line = f'\trmTriggerAddScriptLine("{chunk}");\n'
                                output_lines.append(wrapped_line)
            else:
                print(f"Warning: File '{include_filename}' referenced on line {line_num + 1} was not found. Leaving comment as is.")
                output_lines.append(line)
        else:
            output_lines.append(line)

    # If no output path is provided, default to folder_path / output_filename
    if not output_path:
        final_output_path = os.path.join(folder_path, output_filename)
    else:
        # If output_path is a directory, append default filename to it
        if os.path.isdir(output_path):
            final_output_path = os.path.join(output_path, output_filename)
        else:
            final_output_path = output_path

    # Ensure target parent directories exist if a custom output path was given
    output_dir = os.path.dirname(final_output_path)
    if output_dir:
        os.makedirs(output_dir, exist_ok=True)

    with open(final_output_path, 'w', encoding='utf-8') as out_f:
        out_f.writelines(output_lines)

    print(f"\nSuccess! Compiled file saved to: {final_output_path}")

if __name__ == "__main__":
    target_folder = input("Enter the path to the project folder: ").strip().strip('"').strip("'")
    
    custom_output = input("Enter output path (file or directory) [Press Enter for default]: ").strip().strip('"').strip("'")
    
    # Pass custom_output or None if empty string
    process_xs_template(target_folder, output_path=custom_output if custom_output else None)
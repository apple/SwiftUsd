import argparse
import os
import pathlib
import shutil

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("patch_file", type=os.path.abspath, help="The path to the patch file")
    parser.add_argument("-o", type=os.path.abspath, help="The output directory", required=True, dest="output_dir")
    parser.add_argument("--force", action=argparse.BooleanOptionalAction, default=False, help="Overwrite the destination directory")
    parser.add_argument("--replace-slashes", type=str, default="/", help="Convert foo/bar.txt to foo<SEP>bar.txt")

    args = parser.parse_args()

    if os.path.exists(args.output_dir):
        if args.force:
            if os.path.isdir(args.output_dir):
                shutil.rmtree(args.output_dir)
            else:
                pathlib.Path(args.output_dir).unlink()
            
        else:
            print(f"Error! {args.output_dir} already exists. Remove it, or pass --force to overwrite it.")
            exit(1)

    # Ensure the destination exists
    pathlib.Path(args.output_dir).mkdir(parents=True, exist_ok=True)

    

    with open(args.patch_file, "rb") as f:
        lines = f.readlines()

    out_file = None
    for line in lines:
        if line.startswith("diff ".encode("utf-8")):
            file_in_diff = line.decode("utf-8").split(" ")[-1].strip()
            if file_in_diff.startswith("./"):
                file_in_diff = file_in_diff[2:]
                

            if args.replace_slashes != "/":
                file_in_diff = file_in_diff.replace("/", args.replace_slashes)

            out_file_path = os.path.join(args.output_dir, file_in_diff)
            pathlib.Path(out_file_path).parent.mkdir(parents=True, exist_ok=True)
                
            if out_file is not None:
                out_file.close()
                
            out_file = open(out_file_path, "wb")
            
            
        out_file.write(line)

    out_file.close()



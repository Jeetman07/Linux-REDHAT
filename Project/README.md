Report: Duplicate File Finder And CLeaner

1. Introduction

Managing storage efficiently is essential for computer systems. Over time, duplicate files can build up in directories due to copying, downloading, or backups. These duplicates waste disk space and complicate file management.

The goal of this project is to create a Simple Duplicate File Finder using a Bash shell script. The script scans a directory, identifies duplicate files based on their size and MD5 hash values, and can delete the duplicates to free up disk space.

2. Objectives

The main objectives of this script are:

- To scan a user-specified directory for files.
- To identify duplicate files based on file size and MD5 hash.
- To group duplicate files together.
- To display information about duplicate files clearly.
- To calculate wasted storage space caused by duplicates.
- To allow the user to delete duplicate files if they choose.

3. Tools and Technologies Used

 Tool / Command  Purpose 
 Bash            Shell scripting language used to implement the script 
 find            Used to locate files in directories 
 stat            Retrieves file size information 
 md5sum          Generates hash values for file comparison 
 sort & uniq     Used to detect duplicates 
 grep            Filters matching file entries 
 numfmt          Converts file sizes to human-readable format 

4. Script Workflow

The script works in five main stages:

- Directory input
- File discovery
- Duplicate size detection
- Hash comparison
- Duplicate reporting and optional deletion

5. Script Execution Steps

Step 1: User Input

The script asks the user for a directory path to scan.

Example:

Enter directory to scan (e.g., /home/user or . for current):

The script checks if the directory exists. If the directory does not exist, it terminates with an error message.

Step 2: Finding All Files

The script searches the directory recursively using the find command:

find "$SCAN_DIR" -type f -readable

For each file found:

- The script retrieves the file size using stat.
- It stores the file size and file path in a temporary file.

Format used:

size|filepath

Example:

2048|/home/user/file1.txt  
2048|/home/user/copy_file1.txt

Step 3: Detect Files with Same Size

Files with different sizes cannot be duplicates. The script first identifies files with the same size.

Commands used:

cut  
sort  
uniq -d

This reduces the number of files that need further checking.

Step 4: Generate MD5 Hash Values

For files that match in size, the script generates MD5 hash values.

Command used:

md5sum

Example result:

d41d8cd98f00b204e9800998ecf8427e|file.txt

If two files have:

- The same size
- The same MD5 hash

Then they are true duplicates.

Step 5: Identify Duplicate Groups

The script groups files with identical hash values.

Example output:

Group 1 (Hash: 9e107d9d372bb6826bd81d3542a419d6)

  /home/user/file1.txt  
  /home/user/copy/file1.txt  
  /home/user/backup/file1.txt  

  Each file size: 2 KB  
  Total files: 3  

6. Storage Waste Calculation

The script calculates wasted storage using:

wasted space = file size × (duplicate files - 1)

Example:

File size: 2 KB  

Total duplicates: 3  

Wasted space:

2 KB × (3 − 1) = 4 KB  

The total wasted storage is displayed in a summary.

7. Summary Output

Example summary:

SUMMARY:  
Total duplicate groups: 5  
Total duplicate files: 12  
Total wasted space: 25 MB  

This helps users see how much storage could be saved.

8. Optional Duplicate Deletion

After showing results, the script asks the user:

Do you want to delete duplicates? (yes/no)

If the user answers yes:

The first file in each group is kept.  
All other duplicates are deleted.

Example:

Keeping: /home/user/file1.txt  
Deleted: /home/user/copy_file1.txt  
Deleted: /home/user/backup/file1.txt  

The script also calculates:

- Total files deleted  
- Total storage space freed  

9. Temporary File Management

The script creates temporary files in:

/tmp/duplicate_finder_<processID>

These files store:

- File sizes  
- Hash values  
- Duplicate groups  

After finishing, the script automatically cleans up the temporary directory.

10. Advantages of the Script

- Simple and lightweight  
- Works on any Linux system  
- Efficient duplicate detection  
- Saves storage space  
- User control for deletion  

11. Limitations

- Uses MD5 hashing, which is not the strongest hash algorithm.  
- Large directories may take longer to process.  
- No graphical interface.  
- No advanced filtering options.  

12. Possible Improvements

Future improvements could include:

- Using SHA-256 hashing for stronger verification  
- Adding a GUI interface  
- Allowing file type filtering  
- Parallel processing for faster scanning  
- Automatic backup before deletion  

13. Conclusion

The Simple Duplicate File Finder script offers an effective way to detect duplicate files in a directory. By combining file size comparison and MD5 hashing, the script accurately finds duplicate files and reports wasted storage space. The optional deletion feature enables users to reclaim disk space while maintaining control over their files.


This script shows how Bash scripting and standard Linux tools can be combined to create a practical file management tool.

Disk Usage & IO Analysis
What is Disk Usage?

Disk usage refers to how storage space is consumed by files, directories, logs, applications, and system data.

High disk usage may cause:

Application failures
System slowness
Log write failures
Service crashes

Check Disk Space
View filesystem usage
df -h

Example output:

Filesystem      Size  Used Avail Use%
/dev/sda2        50G   40G   10G   80%


Meaning:

Size → Total disk

Used → Consumed space

Avail → Free space

Use% → Disk utilization

Find Large Directories
Check directory size
du -sh *

## Disk Usage Check

![Disk Usage](Images/disk_usage.png)


Shows folder-wise usage in current directory.

Sort directories by size
du -sh * | sort -hr


Largest directories appear first.

Find Large Files
Files larger than 1GB
find / -type f -size +1G 2>/dev/null


Useful when disk suddenly becomes full.

Check Top Disk Consumers
du -ah / | sort -rh | head -20


Shows top 20 largest files/directories.

Interactive Disk Analyzer (Recommended)

Install:

yum install ncdu -y


or

apt install ncdu -y


Run:

ncdu /


✔ Easy navigation
✔ Fast disk investigation

🔹 Disk IO (Input / Output)

Disk IO measures read/write operations happening on disk.

High IO causes:

System lag

Slow applications

Database delays

Check Disk IO Usage
Using iostat

Install:

yum install sysstat -y


Run:

iostat -x 1


Important fields:

%util → Disk busy percentage

await → IO wait time

r/s → Reads per second

w/s → Writes per second

%util near 100% = disk bottleneck

Check IO Wait (CPU waiting for disk)
top


Look at:

%wa


High value = disk slow or overloaded.

Live Disk Activity
iotop


Shows process-wise disk usage.

Install if missing:

yum install iotop -y

Check Inode Usage

Sometimes disk shows free space but cannot create files.

Check inode usage:

df -i


If inode = 100%, too many small files exist.

Log File Cleanup (Common Fix)

Check logs:

du -sh /var/log/*


Clear old logs safely:

truncate -s 0 /var/log/messages


(or rotate logs using logrotate)

Troubleshooting Workflow (Real Admin Approach)

Check disk space

df -h


Identify large directories

du -sh * | sort -hr


Locate large files

find / -type f -size +500M


Check disk IO

iostat -x 1


Identify heavy processes

iotop


**Real Administrator Scenario**

Example:

During a production alert, disk usage reached 95%.
Using df -h and du -sh, I identified large log files consuming space.
After cleaning old logs and enabling log rotation, disk utilization returned to normal and application performance improved.

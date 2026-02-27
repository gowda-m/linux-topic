**Disk Usage & IO Analysis (Linux)**

**What is Disk Usage?**

Disk usage refers to how storage space is consumed by files, directories, logs, applications, and system data.

**High disk usage may cause:**

Application failures

System slowness

Log write failures

Service crashes

Check Disk Space



View filesystem usage

**df -h**



Find Large Directories

****du -sh *********

![Disk Usage](Images/disk_usage.png)

Disk Usage Meaning

Field	Meaning

Size	Total disk size

Used	Consumed space

Avail	Free space

Use%	Disk utilization



Shows folder-wise usage in current directory.

Sort directories by size

**du -sh * | sort -hr**



Find Large Files

**find / -type f -size +1G 2>/dev/null**




Check Top Disk Consumers

**du -ah / | sort -rh | head -20**




**Interactive Disk Analyzer (Recommended)**

**yum install ncdu -y**

Run: ncdu /

for Easy navigation
 
 Fast disk investigation

Disk IO (Input / Output)



**Disk IO measures read/write operations happening on disk.**

High IO causes:

System lag

Slow applications

Database delays




**Check Disk IO Usage**

**yum install sysstat -y**

Run:
iostat -x 1

Important fields

Field	Meaning

%util	Disk busy percentage

await	IO wait time

r/s	Reads per second

w/s	Writes per second

 %util near 100% = Disk bottleneck.




**Check IO Wait (CPU waiting for disk)**

**top**



High value = Disk slow or overloaded.

**Live Disk Activity**

iotop




Shows process-wise disk usage.

Install if missing:

**yum install iotop -y**

**Check Inode Usage**

Sometimes disk shows free space but files cannot be created.

Check inode usage:

**df -i**

If inode usage = 100%, too many small files exist.





**Log File Cleanup (Common Fix)**

Check logs:

**du -sh /var/log/***


Clear old logs safely:

**truncate -s 0 /var/log/messages**

(or configure log rotation using logrotate)






**Troubleshooting Workflow (Real Approach)**

1️⃣ Check disk space
df -h

2️⃣ Identify large directories
du -sh * | sort -hr

3️⃣ Locate large files
find / -type f -size +500M

4️⃣ Check disk IO
iostat -x 1

5️⃣ Identify heavy processes
iotop

(Real Scenario)

Example:

During a production alert, disk usage reached 95%.
Using df -h and du -sh, large log files were identified consuming disk space.
After cleaning old logs and enabling log rotation, disk utilization returned to normal and application performance improved.

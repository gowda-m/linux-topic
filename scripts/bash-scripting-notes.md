# Bash Scripting Notes

Basic Bash scripting concepts used for Linux administration and automation.

---

# 1. Script Structure

A Bash script is a file containing Linux commands executed sequentially.

### Create Script

```bash
vi gowda.sh
```

### Basic Script Example

```bash
#!/bin/bash

echo "Today is a new day"
```

### Give Execute Permission

```bash
chmod +x gowda.sh
```

### Run Script

```bash
./gowda.sh
```

---

# 2. Basic Commands & Syntax

| Syntax | Meaning |
|------|------|
| `echo` | Prints text to the terminal |
| `read` | Takes input from the user |
| `$` | Access variable value |
| `[ ]` | Condition testing |
| `" "` | String with variable expansion |
| `' '` | Literal string |

Example:

```bash
echo "Hello World"
```

---

# 3. Variables in Bash

Variables are used to store values.

Example:

```bash
#!/bin/bash

name="Gowda"
company="ones"

echo "My name is $name"
echo "I work at $company"
```

Explanation:

```
name  -> variable name
$name -> variable value
```

---

# 4. User Input

`read` is used to take input from the user.

Example:

```bash
#!/bin/bash

echo "Enter your name:"
read name

echo "Hello $name"
```

---

# 5. Conditional Statements (if / else)

Conditional statements are used to make decisions in scripts.

| Keyword | Meaning |
|------|------|
| `if` | Executes commands if condition is true |
| `else` | Executes when condition is false |
| `fi` | Ends the if statement |

Example:

```bash
#!/bin/bash

echo "Enter number:"
read num

if [ $num -gt 10 ]
then
  echo "Number is greater than 10"
else
  echo "Number is less than or equal to 10"
fi
```

### Common Operators

| Operator | Meaning |
|------|------|
| `-gt` | Greater than |
| `-lt` | Less than |
| `-eq` | Equal |
| `-ne` | Not equal |

---

# 6. Loops (for / while / until)

Loops are used to repeat commands multiple times.

| Loop | Purpose |
|------|------|
| `for` | Used when a list is known |
| `while` | Runs while condition is true |
| `until` | Runs until condition becomes true |

Example: For Loop

```bash
#!/bin/bash

for user in root gowda test1
do
  id $user
done
```

Loop syntax:

```
do   -> Start loop commands
done -> End loop
```

---

# 7. Functions

Functions allow reuse of code inside scripts.

Example:

```bash
#!/bin/bash

check_disk() {
  df -h /
}

check_disk
```

Explanation:

```
check_disk() -> function definition
check_disk   -> function call
```

---

# 8. Command Substitution

Command substitution stores command output into a variable.

Syntax:

```bash
variable=$(command)
```

Example:

```bash
#!/bin/bash

today=$(date)

echo "Today date is $today"
```

Another example:

```bash
#!/bin/bash

hostname=$(hostname)

echo "Server name is $hostname"
```

---

# Important Keywords Summary

| Keyword | Meaning |
|------|------|
| `echo` | Print text |
| `read` | Get user input |
| `if` | Condition check |
| `else` | Alternative condition |
| `fi` | End if block |
| `do` | Start loop |
| `done` | End loop |
| `()` | Function declaration |
| `$()` | Command substitution |

---

# Bash Scripting Use Cases

Bash scripting is commonly used for:

- Server monitoring
- Disk usage automation
- User management
- Backup automation
- Log file analysis
- Service monitoring
- System maintenance tasks

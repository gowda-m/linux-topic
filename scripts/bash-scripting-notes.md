Bash Scripting Notes
1️⃣ Script Structure

A Bash script is a file containing Linux commands executed sequentially.

Create a script:

vi gowda.sh

Basic structure:

#!/bin/bash

echo "Today is a new day"

Give execute permission:

chmod +x gowda.sh

Run the script:

./gowda.sh
Basic Commands & Syntax
Syntax	Meaning
echo	Prints text to the screen
read	Takes input from user
$	Access variable value
[ ]	Condition test
" "	String with variable expansion
' '	Literal string

Example:

echo "Hello World"
2️⃣ Variables in Bash

Variables store values.

Example:

#!/bin/bash

name="Gowda"
company="ones"

echo "My name is $name"
echo "I work at $company"

Explanation:

name → variable name
$name → variable value
3️⃣ User Input

read takes input from the user and stores it in a variable.

Example:

#!/bin/bash

echo "Enter your name:"
read name

echo "Hello $name"
4️⃣ Conditional Statements (if / else)

Used to make decisions in a script.

Keyword	Meaning
if	Executes commands if condition is true
else	Runs when condition is false
fi	Ends the if statement

Example:

#!/bin/bash

echo "Enter number:"
read num

if [ $num -gt 10 ]
then
  echo "Number is greater than 10"
else
  echo "Number is less than or equal to 10"
fi

Common operators:

Operator	Meaning
-gt	Greater than
-lt	Less than
-eq	Equal
5️⃣ Loops (for / while / until)

Loops repeat commands multiple times.

Loop	Purpose
for	Used when you have a known list
while	Runs while condition is true
until	Runs until condition becomes true

Example:

#!/bin/bash

for user in root gowda test1
do
  id $user
done

Loop syntax:

do   → Start loop commands
done → End loop
6️⃣ Functions

Functions allow reuse of code.

Function definition:

hello() { }

Example:

#!/bin/bash

check_disk() {
  df -h /
}

check_disk

Explanation:

check_disk() → function definition
check_disk   → function call
7️⃣ Command Substitution

Stores command output inside a variable.

Syntax:

variable=$(command)

Example:

#!/bin/bash

today=$(date)

echo "Today date is $today"

Another example:

#!/bin/bash

hostname=$(hostname)

echo "Server name is $hostname"
Important Keywords Summary
Keyword	Meaning
echo	Print text
read	Get user input
if	Condition check
else	Alternative condition
fi	End if block
do	Start loop
done	End loop
()	Function declaration
$()	Command substitution

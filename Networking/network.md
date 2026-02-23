**1 IP Configuration**

Instead of:

ip addr command

Write:

## Scenario
Application server not reachable after reboot.

## Investigation
- Checked interface status using ip a
- Observed IP missing

## Root Cause
NetworkManager profile misconfigured.

## Fix
nmcli connection up eth0

👉 This shows real experience.

**2️ Routing Basics → Senior Thinking**

Add:

## Production Issue
Server has two NICs.
Outgoing traffic using wrong gateway.

## Analysis
ip route showed multiple default routes.

## Solution
Configured route metric priority.

This = L3 knowledge.

**3️ Advanced Routing (Very Strong Section)**

Add real cases:

Use Case:
Backup network separated from production network.

Solution:
Policy Based Routing implemented.

Hiring managers LOVE this.

**4️ tcpdump Section (MOST IMPORTANT)**

Write like:

Problem:
Website accessible internally but not externally.

Action:
tcpdump -i eth0 port 443

Observation:
No incoming packets.

Conclusion:
Firewall blocking upstream.

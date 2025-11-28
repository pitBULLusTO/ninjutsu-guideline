# I. Brainstorming different methods

---

## 1. Context and goals

* Adversary: intelligence services (FSB) with access to ISPs and the ability to analyze traffic and metadata.
* Goal: not only to hide the content, but also **the very fact of communication and the link “who is talking to whom”**.
* Constraints: only **open source**, preferably cross-platform, text + files; convenience and speed are not critical.

---

## 2. Base layer: anonymous networks

Used almost always as the “foundation”:

* **Tor** – the main tool: hides IP and route, allows using .onion services (hidden services without exit to the regular internet).
* **I2P** – an analogue of Tor, more focused on internal services and asynchronous exchange.
* **Mix networks (Mixmaster/Mixminion, Nym, etc.)** – slow but maximally anonymous for sending emails/messages (hide metadata very well, but not suitable for real-time chat).
* **VPN/SSH** – additions, but not a “shield” from the state by themselves; used only as an extra layer on top of Tor/others.

---

## 3. Protocols and messengers

### 3.1. Classic: XMPP and Matrix

* **XMPP (Jabber) + OTR/OMEMO over Tor**

  * Anonymous accounts on servers with .onion addresses or your own XMPP server as a hidden service.
  * End-to-end encryption (OTR/OMEMO) + Tor ⇒ a good balance of “anonymity + flexibility”.
  * Cons: needs configuration; with poor configuration, metadata leaks.

* **Matrix (Element, etc.) over Tor + your own server**

  * Encryption by default, groups, files.
  * But Matrix is “heavy” and strongly tied to servers/federation; without your own onion server and strict Tor-only mode, metadata leaks much more.

### 3.2. P2P messengers without servers

* **Tox, Jami, RetroShare, Bitmessage, etc.**

  * Pros: no central server, encryption by default.
  * Cons: any P2P by default **exposes your IP** at least to the contact; you need to run it over Tor/an anonymous tunnel, which makes things more complicated.
  * Bitmessage/RetroShare are suitable for asynchronous/niche scenarios, but are heavy and not very popular.

### 3.3. Messengers on Tor hidden services

* **Ricochet / Ricochet Refresh** – each client is its own onion server, one-to-one chat, no central server. Very anonymous, but **no offline**: both must be online.
* **Cwtch** – develops the idea of Ricochet: onion addresses + intermediate servers inside Tor for offline delivery. Promising, but still not a “mass product”.
* **OnionShare (chat/file mode)** – one-time chats and file transfer via a temporary onion service; excellent for one-off sessions and file drops.

### 3.4. New generation of private messengers

* **Session**

  * No phone number/email; the identifier is a random ID.
  * End-to-end encryption based on the Signal protocol + its own “onion” network of nodes (Oxen) for routing and storing offline messages.
  * Supports files, groups, multi-platform. A good “universal” option.

* **SimpleX Chat**

  * **No user IDs at all**: only one-time links/QR codes and separate message queues for each pair of interlocutors.
  * Servers see only encrypted queues, without knowing who is talking to whom.
  * Very strong metadata protection, but less familiar UX (you need to exchange invite links).

* **Briar**

  * Android only, all traffic goes through Tor or directly over Bluetooth/Wi-Fi, without servers.
  * Designed for activists and to work even when the internet is shut down.
  * Strong anonymity and resistance to censorship, but limited platform and functionality.

**Practical takeaway:** in real use people most often combine **Session / SimpleX / Briar** (depending on the situation) as the main anonymous messenger + Tor/OnionShare/extra tools for files and “one-off” tasks.

---

## 4. Asynchronous and “old-school” methods

* **Email over Tor + PGP/GPG**

  * Anonymous mailboxes (ProtonMail, etc.) + access only via Tor.
  * For maximum protection – remailer/mixnet networks (Mixmaster/Mixminion), but that is complex and slow.

* **Digital “dead drops”**

  * Shared account/storage, a pastebin/file-sharing service in Tor where one person places encrypted text/file and the other retrieves it.
  * Hides the sender–receiver link well, but is inconvenient and non-interactive.

---

## 5. Critically important OPSEC layer

Any of these tools becomes useless if:

* The device is compromised (malware, physical access).
* Network access is not anonymized (Tor only half-used, VPN with logs, etc.).
* From behavior, activity time and message content your identity can be inferred.

Recommended:

* For especially important sessions – a separate environment (for example, Tails or a separate phone with a privacy-focused ROM).
* Always access anonymous messengers via Tor/an anonymous channel, avoid linking them to personal accounts/numbers.
* Minimize metadata: irregular sessions, one-time identifiers, minimal personal information in text.

---

If you like, in the next step I can:

* suggest **concrete turn-key combos** (for example, a bundle: XMPP server + Tor + clients; or “Session + OnionShare + Tails”),
* or make a **comparison table** by criteria: anonymity, convenience, setup complexity, file support.

------------

# II. Matrix #1

## 1. How I calculated (first principles)

**Goal:** maximum anonymity with *sufficient* convenience.

We break the goal down into the basic properties of any communication method:

* **A — Anonymity (0–10)**  
  How hard it is for the FSB to link *you* to the correspondence if you do everything correctly (Tor/I2P, no side accounts).
* **M — Metadata (0–10)**  
  How well *who talks to whom* is hidden: social graph, time and frequency of messages.
* **C — Convenience (0–10)**  
  How similar it is to a normal messenger: speed, UI, online/offline, etc.
* **R — Reliability/maturity (0–10)**  
  How alive, tested and non-alpha the project is.
* **F — File handling (0–10)**  
  How easy it is to send files (not only text).

Your wording “maximum anonymity with relative convenience” ⇒  
I took the weights as:

* Anonymity **A** – 0.35
* Metadata **M** – 0.25
* Convenience **C** – 0.15
* Reliability **R** – 0.15
* Files **F** – 0.10

Resulting **utility coefficient**:

> **U = 0.35·A + 0.25·M + 0.15·C + 0.15·R + 0.10·F**

All 0–10 scores are expert estimates based on protocol design and public docs (Tor, I2P-Bote, SimpleX, Session, OnionShare, Briar, Cwtch, Ricochet, RetroShare, etc.).  
It is assumed that the configuration is **correct** (Tor/I2P everywhere it should be) and that there is no malware on the devices.

---

## 2. Summary table (from best U to worst)

> **Important:** this is not “absolute truth”, but a normalized comparison *between them* for your goal and threat model (FSB).

| #  | Method                                 | Type/short description                         | Anonymity A | Metadata M | Convenience C | Reliability R | Files F | U (coef.) |
| -- | -------------------------------------- | ---------------------------------------------- | ----------- | ---------- | ------------- | ------------- | ------- | --------- |
| 1  | **SimpleX Chat**                       | SimpleX (no user identifiers)                  | **9**       | **10**     | 7             | 7             | 8       | **8.6**   |
| 2  | **Session messenger**                  | Session (Oxen onion network, no phone number)  | **9**       | 8          | 8             | 8             | 8       | **8.4**   |
| 3  | **OnionShare (chat + file share)**     | OnionShare chat/files over Tor                 | **9**       | **9**      | 4             | 8             | **10**  | **8.2**   |
| 4  | **Briar**                              | Briar (Tor + Bluetooth/Wi-Fi, no servers)      | **9**       | **9**      | 6             | 8             | 6       | **8.1**   |
| 5  | **Ricochet Refresh**                   | P2P chat over Tor onion (Ricochet)             | 9           | 9          | 5             | 6             | 8       | 7.9       |
| 6  | **Cwtch**                              | Decentralized Tor messenger (metadata-resistant) | 9         | 9          | 6             | 5             | 8       | 7.9       |
| 7  | **I2P-Bote email**                     | Email inside I2P-Bote                          | 9           | 9          | 5             | 5             | 6       | 7.5       |
| 8  | **RetroShare over Tor/I2P**            | RetroShare over Tor/I2P                        | 8           | 6          | 6             | 7             | 9       | 7.1       |
| 9  | Self-hosted XMPP onion-only            | Own XMPP server as an onion service            | 8           | 5          | 6             | 7             | 7       | 6.7       |
| 10 | XMPP+OTR/OMEMO via public onion server | XMPP (public server) + OTR/OMEMO over Tor      | 7           | 4          | 7             | 9             | 7       | 6.5       |
| 11 | Tox over Tor                           | Tox messenger over Tor                         | 7           | 6          | 6             | 6             | 8       | 6.5       |
| 12 | Tor+webmail+PGP                        | Email over Tor + PGP (ProtonMail/etc.)         | 7           | 3          | 7             | 9             | 9       | 6.5       |
| 13 | Mixmaster remailer email               | Email via remailers/mixnet                     | 9           | 8          | 2             | 4             | 4       | 6.5       |
| 14 | Self-hosted Matrix onion-only          | Own Matrix homeserver as an onion service      | 7           | 5          | 6             | 7             | 8       | 6.4       |
| 15 | Matrix via public server over Tor      | Matrix (public homeserver) over Tor            | 6           | 3          | 8             | 8             | 8       | 6.0       |

Briefly, why the top looks like this:

* **SimpleX Chat** – by design does not use user identifiers at all: no logins, no phone numbers, no permanent IDs; SimpleX servers do not store accounts, they only forward encrypted queues for a particular pair of interlocutors, with no shared metadata between chats.  
  When used over Tor you get *very* strong anonymity + normal usability.

* **Session** – a fork of Signal that removed phone numbers and the centralized server: messages are routed through a decentralized network of Oxen service nodes with onion routing, registration is fully anonymous.  
  Metadata is heavily minimized, but there is a stable pseudonym (Session ID).

* **OnionShare** – not a classic messenger, but a “one-time anonymous server”: via a Tor onion service you run a temporary site/chat/file share directly on your machine, without third-party servers and logs.  
  Maximum anonymity and near-zero metadata, but less convenience (one-time sessions, manual link sharing).

* **Briar** – fully decentralized, no servers: when the internet is available it works via Tor, and when it isn’t – over Bluetooth/Wi-Fi mesh, synchronizing messages while preserving anonymity and network connectivity.

* **Ricochet Refresh / Cwtch** – both are built on Tor onion services, work P2P and are designed specifically to be metadata-resistant: no central server, contacts are onion addresses, connections go via Tor hidden services.

* **I2P-Bote** – serverless email inside I2P: messages are encrypted and stored in a distributed DHT, with the possibility of sending via a chain of relay nodes to increase anonymity; metadata is maximally hidden.

---

## 3. How to interpret this in practice

If we translate the table from numbers into “what to actually install and use”:

### Main anonymous chat “for everyday use”

* **SimpleX Chat** – the best balance according to our function:

  * top-tier anonymity and metadata protection (no IDs, no overall contact graph);
  * clients for Linux/Android/iOS/desktop;
  * support for files, groups, voice messages.

* **Session** – a bit easier to understand and set up, looks like a classic messenger but without a phone number, on top of the Oxen onion network.

**Combo:** SimpleX as the main one, Session as a backup channel/for people for whom it’s hard to explain SimpleX.

### For especially sensitive files and one-time sessions

* **OnionShare** – turn it on → get an onion link → send it to contacts → chat/transfer files → turn it off ⇒ the server disappears, almost no traces. Great as a “one-time safe” and anonymous file dropbox.

* **Ricochet Refresh / Cwtch** – if you need a permanent but maximally anonymous P2P line over Tor onion, with no servers and minimal metadata.

### For asynchronous correspondence (mail)

* **I2P-Bote** – top choice for anonymous mail if you are not afraid of I2P: serverless, encrypted DHT, the ability to send via a chain of relay nodes.
* **Mixmaster remailers** – theoretically even more anonymous, but in 2025 it’s painful in terms of usability and liveliness of the infrastructure.

### “Traditional” XMPP/Matrix/RetroShare/Tox

* **XMPP+OTR/OMEMO over Tor** and **RetroShare over Tor/I2P** remain good if you want:

  * compatibility with the existing ecosystem (XMPP clients, bots, gateways);
  * or a friend-to-friend network (RetroShare) with powerful encrypted file sharing.

* **Matrix** (even self-hosted over onion) loses in terms of metadata: a very “chatty” protocol and a heavy server.

---

## 4. What I would choose for your scenario

If we look strictly according to this model (FSB-level adversary, open source, Linux/mobiles, anonymity > convenience), then:

1. **Messenger by default:**

   * **SimpleX Chat** (primary)
   * **Session** (fallback / for other people)

2. **Strong channel for especially sensitive things:**

   * **OnionShare** (chat + receive-mode as a dead drop)
   * or **Ricochet Refresh / Cwtch** for a permanent but very quiet channel.

3. **Asynchronous mail:**

   * **I2P-Bote** (if you are ready to live with I2P)
   * or Tor + anonymous webmail + PGP as a “less ideal but more familiar” option.

------------

# III. Matrix #2 (- convenience)

New weights:

* **Anonymity (A)** – 0.35
* **Metadata (M)** – 0.25
* **Reliability/maturity (R)** – 0.25
* **Files (F)** – 0.15

New utility formula:

> **U = 0.35·A + 0.25·M + 0.25·R + 0.15·F**

(check using OnionShare as an example: `0.35*9 + 0.25*9 + 0.25*8 + 0.15*10 = 8.9`)

---

## 1. Updated table (without convenience)

I keep the underlying A/M/R/F scores the same (as we already discussed); we only change the weights.

| #  | Method                                      | A | M  | R | F  | New U    |
| -- | ------------------------------------------- | - | -- | - | -- | -------  |
| 1  | **OnionShare (chat + files)**               | 9 | 9  | 8 | 10 | **8.90** |
| 2  | **SimpleX Chat**                            | 9 | 10 | 7 | 8  | **8.60** |
| 3  | **Session messenger**                       | 9 | 8  | 8 | 8  | **8.35** |
| 4  | **Briar**                                   | 9 | 9  | 8 | 6  | **8.30** |
| 5  | **Ricochet Refresh**                        | 9 | 9  | 6 | 8  | **8.10** |
| 6  | **Cwtch**                                   | 9 | 9  | 5 | 8  | **7.85** |
| 7  | **I2P-Bote (mail in I2P)**                  | 9 | 9  | 5 | 6  | **7.55** |
| 8  | **RetroShare over Tor/I2P**                 | 8 | 6  | 7 | 9  | **7.40** |
| 9  | **Self-hosted XMPP onion-only**             | 8 | 5  | 7 | 7  | **6.85** |
| 10 | **Tor + webmail + PGP**                     | 7 | 3  | 9 | 9  | **6.80** |
| 11 | **Mixmaster remailers**                     | 9 | 8  | 4 | 4  | **6.75** |
| 12 | **XMPP+OTR/OMEMO (public onion server)**    | 7 | 4  | 9 | 7  | **6.75** |
| 13 | **Tox over Tor**                            | 7 | 6  | 6 | 8  | **6.65** |
| 14 | **Self-hosted Matrix onion-only**           | 7 | 5  | 7 | 8  | **6.65** |
| 15 | **Matrix (public homeserver) over Tor**     | 6 | 3  | 8 | 8  | **6.05** |

(I rounded to two decimal places; internally I calculated more precisely.)

---

## 2. How the balance of power changed

When we removed convenience and strengthened **reliability**, the lineup shifted slightly:

* **OnionShare moved into first place** — it has extremely high scores for anonymity/metadata and perfect file handling, and its reliability is high: mature code, active project, built on top of Tor.
* **SimpleX** and **Session** remained in the top-3, but now slightly lose to OnionShare precisely because OnionShare has F=10 and very high A/M, with reliability 8.
* **Briar** moved closer to Session (high anonymity, good metadata and reliability, but weaker in files).
* Methods like **Mixmaster, Tor+webmail+PGP** moved up a bit relative to “chatty” Matrix/XMPP, because they have good reliability with low metadata, but overall they are still pushed down by the leaders.

---

## 3. Conclusion in terms of “first principles”

If we formalize:

1. **Fundamental goal** → minimize the probability of deanonymization + reconstruction of the social graph, while having a working (mature) tool that can transfer not only text but also files.

2. We explicitly **removed convenience** from the equation ⇒ any loss in UX does not matter if the solution scores well on A/M/R/F.

3. With these assumptions, the top strategy is:

   * **OnionShare**

     * Use it as the **base tool for especially sensitive sessions** and file exchange: bring up a temporary onion service → give the link to contacts → exchange data → shut it down.

   * **SimpleX / Session / Briar**

     * Keep them as **permanent channels**, where you already have a normal chat and don’t need to fuss with one-time links every time.

       * SimpleX – maximum on metadata protection,
       * Session – slightly more convenient and stable,
       * Briar – its own class (Tor + offline mesh), especially if you expect internet/censorship problems.

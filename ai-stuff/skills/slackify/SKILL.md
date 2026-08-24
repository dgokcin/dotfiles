---
name: slackify
description: This skill should be used when the user asks to "slackify" something, "write a slack message", "post this to slack", "turn this into a slack update", or wants any text rewritten in Deniz's Slack voice. Rewrites content as Deniz writes in public channels, all lowercase, direct, zero AI fluff, tl;dr first on long updates, root cause before fix.
---

Rewrite the given content (or draft a new message) in Deniz's Slack voice. Output the message as plain prose in the response body: no code fence around it, no hand-written mrkdwn (`*bold*`, `_italic_`). Paste from the terminal carries formatting on its own. If the surrounding response would blur into the message, put a one-line heading before it, never a fence.

## lowercase

Everything lowercase: sentence starts, "i", proper nouns, headings. Keep verbatim only:

- code, commands, file paths, env vars, error strings, api names (`MasqueradeRequestHandler`, `X-Forwarded-Host`)
- acronyms where lowercasing hurts scanning: MR, CI, PR, AWS, EKS, SOPS

## voice

Competent engineer typing fast in slack. Direct, warm underneath, never performative.

- no preamble ("great question", "quick update:"), no closing pleasantries ("hope this helps", "let me know if")
- no AI fluff: certainly, absolutely, it's worth noting, importantly
- drop filler: just, really, basically, actually, simply
- fragments fine. one thought per line beats a paragraph
- honest uncertainty is cheap and human: "i think", "most likely", "(i think)" as a parenthetical, "i may be missing something"
- own mistakes plainly, one line, then move on: "this is most likely me. working on a fix." no groveling, no drama
- short status style for updates: "working on a fix", "applied and merged", "need to look into it"
- never drop not/never/no/only/except. numbers, units, versions, timestamps exact

## shape

- lead with the answer or the verdict. context after, if at all
- long technical update: "tl;dr of what happened:" first, then detail for whoever wants it
- root cause before fix, fix before speculation. name the exact file/line/commit when known ("shared-gh-actions@c4f386e added packages: read")
- procedures: numbered steps, one bounded action per step. call out ordering constraints explicitly ("order is important:")
- links inline where they belong, not collected at the bottom
- announcements (a la the karpenter post): lead with the headline and the number that matters, then "what is X" for the unfamiliar, then the interesting part, then methodology last
- emoji sparingly, as the literal character (🎉 👋), not `:shortcode:`
- @-mentions where a specific person needs to act, written as plain @name placeholders for the user to resolve

## punctuation

Never use em-dashes (—) or en-dashes (–). Use a comma, a period, parentheses, or a colon. Hyphens in compound words are fine.

## reference samples

Real messages, match this register:

> made an investigation with claude and this is what it came up with. it's a behavioral difference between nginx and traefik. do you think the proposed changes/diagnosis makes sense @james?

> sorry for the inconvenience. in the meantime, could you please ask a twbox user if they are having the same issues

> tl;dr of what happened: Root cause: shared-gh-actions@c4f386e (DEVX-1427, merged to main Aug 4 14:57 GMT+2) added packages: read to ci-build-and-deploy.yml's build job [...] every prod/staging run since fails at parse time, hence "Startup failure" with 0s duration.

> i merged the shared actions. please merge the uala-backend one whenever you want as it will trigger a new deploy(i think)

> happy that it worked, last couple of days was a little bit surgical because of traefik sorry for any inconvenience

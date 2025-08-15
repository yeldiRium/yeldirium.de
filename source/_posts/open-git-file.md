---
layout: post
title: Opening a file from a git repository in the browser
date: 2025-08-15 15:34:44
tags:
  - Bash
  - NeoVim
category:
  - development
  - workstation
---

In my day-to-day engineering workflow I mainly work with GitLab to collaborate with other engineers. I use Gitea or GitHub for personal projects and thus use multiple platform daily.
Especially when collaborating with others, I often find the need to reference code in conversations, jira issues or other contexts and need to navigate to a certain file in the GitLab GUI. This always takes forever and annoys me to no end, since in my workflow I usually don't even know the path of the file I'm currently looking at. Since I prefer to navigate my projects using [fzf](https://github.com/junegunn/fzf) or [telescope](https://github.com/nvim-telescope/telescope.nvim), I usually don't need to know the exact location of a file. But if I want to find the file in the web GUI to link it to someone, I need to navigate through the file hierarchy.

A lot of the fun I have when programming comes from improving and customizing my workstation. So naturally my next reflex was to think: "How can I open this file in the GUI directly from my editor"? And of course I did not think about whether someone had already done that, since it's much more fun to do it myself.

So I needed to achieve multiple goals:

1. Find the relative path of the file within the git repository
2. Find the remote git host and determine what kind of host it is (GitHub, GitLab, Gitea, others?)
3. Generate the right URL and open it

Also, error handling.

The second part was the hardest, since with self-hosted Gitea and GitLab instances there really is no way to tell them apart by their URL or git behavior. Following the german credo "stumpf ist trumpf" I checked their output when SSH-ing into them and voila - each of them has different output and they identify themselves:

```
:> ssh git.staubwolke.org
PTY allocation request failed on channel 0
Hi there, yeldir! You've successfully authenticated with the key named <keyname>, but Gitea does not provide shell access.
If this is unexpected, please log in with password and setup Gitea under another user.
Connection to git.staubwolke.org closed.

:> ssh github.com
PTY allocation request failed on channel 0
Hi yeldiRium! You've successfully authenticated, but GitHub does not provide shell access.
Connection to github.com closed.
```

So I just checked the output for the strings "GitHub", "Gitea" and "GitLab". I don't support any other hosts yet, since I don't use any others.

[Here's](https://github.com/yeldiRium/nix-config/blob/main/modules/home-manager/yeldirs/cli/essentials/scripts/open-git-file) the script and I also [integrated it with NeoVim](https://github.com/yeldiRium/nix-config/blob/main/modules/home-manager/yeldirs/cli/essentials/neovim/bindings.lua#L68-L71).

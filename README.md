
# ✨ crosboot

crosboot is a handy tool for tweaking your ChromeOS boot screen

## ⚠️ Warning

Just so you know, crosboot is in beta. While nothing should mess up your OS, it's a good idea to back up your default boot screen just in case crosboot didn’t save it. 
(better safe than sorry!!)

## Before you start - [source](https://gist.github.com/supechicken/c57f8bb4b9dad2a29611ce05b1324b5c?permalink_comment_id=4444479#before-you-start)

- Enable Chrome OS developer mode
- Disable root filesystem verification, remount root filesystem as read/write

---

- make sure you have ready your boot gif as png images.
- [iOS Video to ChromeOS boot splash shortcut](https://www.icloud.com/shortcuts/71343bb25d1446e19ee9c99182a7d223)

## Usage

```shell
cd; curl -LO sayborduu.github.io/crosboot/crosboot.sh && sudo bash crosboot.sh
```

## Authors

- [@sayborduu](https://www.github.com/sayborduu)

## Tips

- Feel free to whip up your own folder stuffed with different boot screens (just keep each one in its own folder).
- You can totally use apps like CapCut on iOS to make a cool video for your boot screen, then check out [this shortcut](https://www.icloud.com/shortcuts/71343bb25d1446e19ee9c99182a7d223) to convert it to PNG and rename it to fit ChromeOS's boot screen format.

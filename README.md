# Desktop Icons for eOS/Pantheon


> [!WARNING]
> **NOT MAINTAINED because I long moved from Pantheon to GNOME, but feel free to commit or fork!**
> 
> Last eOS version to work well is **7.1**, on **8.0+** things **will** break, especially if you use Wayland.
>
> In particular, Win+D shortcut will not work anymore, and AFAIK there is no way to re-implement it on Wayland because there are no Wayland alternatives to `xdotool`.
>
> Nemo install will also fail because dependencies have changed quite a bit. Use `apt install nemo-desktop` instead, and then run `install.sh` from the moment of applying tweaks.


![image](https://github.com/user-attachments/assets/c298ecdd-6226-426e-ab2e-1786117fe888)

Most of current approaches re-invent the wheel and create their own desktop icons from scratch.

However, why not just use polished and well-maintained desktop icons implementations from other DEs that provide it as a separate component?

And this exactly what this project aims to do — it installs either `xfdekstop4` (from XFCE) or `nemo-desktop` (from Nemo) with a few customization tweaks and small fixes, this way providing well-working desktop icons that look very native-like. It also installs a custom `Win+D` shortcut that allows to show/hide desktop quickly.

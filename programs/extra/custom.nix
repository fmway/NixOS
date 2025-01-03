{ super, lib, self, ... }:
{
  git = super.git;
  obs-studio = self.wrapOBS {
    plugins = with self.obs-studio-plugins; [
      wlrobs
      obs-backgroundremoval
      obs-pipewire-audio-capture
    ];
  };
  swayfx = (self.swayfx-unwrapped.override {
    trayEnabled = false;
  });
}

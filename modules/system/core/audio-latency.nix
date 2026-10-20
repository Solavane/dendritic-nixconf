{
  flake.modules.nixos.audio-latency = { ... }: {
    # Real-time privileges for members of the `audio` group. Without these the
    # JACK graph can only borrow real-time priority through rtkit, which wakes
    # up late under load; with them PipeWire/WineASIO threads can be scheduled
    # SCHED_FIFO directly and lock their buffers. `nice -19` keeps the audio
    # threads ahead of ordinary work if they ever end up at normal priority.
    security.pam.loginLimits = [
      {
        domain = "@audio";
        item = "rtprio";
        type = "-";
        value = "95";
      }
      {
        domain = "@audio";
        item = "memlock";
        type = "-";
        value = "unlimited";
      }
      {
        domain = "@audio";
        item = "nice";
        type = "-";
        value = "-19";
      }
    ];

    # FL Studio reaches PipeWire through WineASIO's JACK backend, so the graph
    # quantum *is* the ASIO buffer size. The stock 1024-frame quantum is ~21 ms
    # at 48 kHz; 256 frames brings that to ~5 ms. The wider min/max window still
    # lets PipeWire stretch the quantum under load instead of xrunning, and the
    # rate is pinned so the DAW does not resample the whole graph at 44.1 kHz.
    services.pipewire.extraConfig.pipewire."10-low-latency" = {
      "context.properties" = {
        "default.clock.rate" = 48000;
        "default.clock.quantum" = 256;
        "default.clock.min-quantum" = 64;
        "default.clock.max-quantum" = 1024;
        "default.clock.quantum-limit" = 2048;
      };
    };
  };
}

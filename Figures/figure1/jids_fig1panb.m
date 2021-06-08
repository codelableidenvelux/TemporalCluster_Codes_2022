%% create example JIDs - Figure 1 panel b
% load('../../138ee6d165fa06954ba1bed56719415b12dd28eb.mat')
load('../../138ecd4b9fbd996b43b98efb10ab69adea1128eb.mat')

fullJID = FullJID(Phone.taps.taps);
socialJID = SocialJID(Phone.taps, Phone.apps);
launcherJID = LauncherJID(Phone.taps, Phone.apps);
transitionJID = TransitionJID(Phone.taps, Phone.apps);

%% plot them
subplot(2,2,1)
imagesc(fullJID)
title("Full")
subplot(2,2,2)
imagesc(socialJID)
title("Social")
subplot(2,2,3)
imagesc(launcherJID)
title("Launcher")
subplot(2,2,4)
imagesc(transitionJID)
title("Transition")

%% save them
save('ex_all_jids.mat', 'fullJID', 'socialJID', 'launcherJID', 'transitionJID');
function estMap = produceBestMap(estMap,spMask,imMap,predConf)

[~,I] = max(predConf);
bestMap = uint8(imMap{I(1)});

spIdx = find(spMask==1);
estMap(spIdx) = bestMap(spIdx);


end
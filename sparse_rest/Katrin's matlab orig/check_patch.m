function check_patch(opt,AZ,FLIPX,FLIPY)
    % opt = 'standard' or 'nordic';

    pth = fullfile(filesep,'Volumes','gdrive','mri','ProcData','SimHL',opt);   
    load(fullfile(pth,'patch','patch.mat'),'ptch')

    vtc = ptch.flat;
    if FLIPX, vtc(:,1) = -vtc(:,1); end
    if FLIPY, vtc(:,2) = -vtc(:,2); end
    tri = ptch.tri;
    curv = -fthrcurv(ptch.curv,25);
    pbdry = vtc(ptch.bdry,:);

    figure, hold on
    xlim = [min(vtc(:,1)) max(vtc(:,1))];
    ylim = [min(vtc(:,2)) max(vtc(:,2))];

    cmap = colormap('gray'); RANGE = 0.5; OFFSET = min(1-RANGE,0.2);
    cidx = round((RANGE/(max(curv)-min(curv))*(curv-min(curv))+OFFSET)*(size(cmap,1)-1))+1;
    patch('vertices',vtc,'faces',tri,'FaceVertexCData',cmap(cidx,:),'FaceColor','interp','Edgecolor','none')
    plot(pbdry(:,1),pbdry(:,2),'Color','blue','LineWidth',3) 

    set(gca,'XLim',xlim,'YLim',ylim,'View',[AZ 90]) 
end

function curv = fthrcurv(curv,SLOPE)

    curv = erf(SLOPE*2/sqrt(pi)*curv/max(abs(curv(:))));    
end

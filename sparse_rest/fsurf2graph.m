function [G,adjmtx] = fsurf2graph(vtc,tri)

    N = size(vtc,1);

    i1=tri(:,1); 
    i2=tri(:,2);
    i3=tri(:,3);
    
    cncts =[[i1 i2];[i1 i3];[i2 i3]]; 
    dstcs = cellfun(@(x) norm(vtc(x(1),:)-vtc(x(2),:)),num2cell(cncts,2)); 
    
    adjmtx = sparse(cncts(:,1),cncts(:,2),dstcs,N,N);
    adjmtx=adjmtx+(adjmtx');
    
    nams = arrayfun(@(x) sprintf('%d',x),1:N,'UniformOutput',false);
    G = graph(adjmtx,nams); 
end
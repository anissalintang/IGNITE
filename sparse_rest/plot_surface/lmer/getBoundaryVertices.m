% Function to get boundary vertices from mask
function boundary_vertices = getBoundaryVertices(mask_path, surf)
    lh_mask = MRIread(mask_path);
    lh_mask_logical = (lh_mask.vol > 0);
    dilated_mask = lh_mask_logical;
    for i = 1:length(lh_mask_logical)
        if lh_mask_logical(i)
            neighbors = surf.tri(any(surf.tri == i, 2), :);
            neighbors = unique(neighbors(:));
            dilated_mask(neighbors) = 1;
        end
    end
    boundary_mask = dilated_mask & ~lh_mask_logical;
    boundary_vertices = find(boundary_mask);
end
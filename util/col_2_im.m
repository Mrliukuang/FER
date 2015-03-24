function im = col_2_im(X_size, cols, filter_h, filter_w, pad, stride)
% [H, W, C, N] = size(X);
%     pad = conv_param.pad;
%     stride = conv_param.stride;
    H = X_size(1);
    W = X_size(2);
    C = X_size(3);
    N = X_size(4);
% Method #1: using c
   im = col_2_im_c(cols, [H+2*pad, W+2*pad, C, N], [filter_h, filter_w], stride);
    
% Method #2
%     HH = (H + 2*pad - filter_h) / stride + 1;
%     WW = (W + 2*pad - filter_w) / stride + 1;
%     im = zeros(H+2*pad, W+2*pad, C, N);
%     i = 1;
%     j = 1;
%     for n = 1 : HH*WW
%         col = cols(:, (n-1)*N+1 : n*N);
%         sq = reshape(col, [filter_h, filter_w, C, N]);
%         im(i:i+filter_h-1, j:j+filter_w-1, :, :) = ...
%             im(i:i+filter_h-1, j:j+filter_w-1, :, :) + sq;
%         
%         i = i + stride;
%         if i > H+2*pad-filter_h+1
%             i=1;
%             j=j+stride;
%         end
%     end
    
    im = im(1+pad:end-pad, 1+pad:end-pad, :, :);
    
end
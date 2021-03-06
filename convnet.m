% clear; 
clc; close all;

% load convdata.mat;
% load CIFAR10_3D_zero_meaned.mat;
X = X_tr;
model = init_convnet_model(X(:,:,:,1));

% load parameters
W1 = model.W{1};    % 5*5*1*32
b1 = model.b{1};    % 32*1
W2 = model.W{2};    % 6272*10
b2 = model.b{2};    % 10*1

% H = height
% W = weight
% C = image channels, 1 for gray image, 3 for RGB image
% N = # of examples
[H, W, C, N] = size(X); % 28*28*1*60000


% filter_h == filter_w, the filter is square
[filter_h, filter_w, ~, filter_n] = size(W1);

% convolute params.
conv_param.stride = 1;
conv_param.pad = (filter_h-1)/2;

% HH = (H + 2 * conv_param.pad - filter_h) / conv_param.stride + 1;
% WW = (W + 2 * conv_param.pad - filter_w) / conv_param.stride + 1;

% pool params.
pool_param.stride = 1;
pool_param.height = 2;
pool_param.weight = 2;

% load validation data
val_ind = randi(N, 1000, 1);
X_val = X(:, :, :, val_ind);
y_val = y_tr(val_ind);

best_acc = 0;
best.loss = Inf;
best.W1 = W1;
best.b1 = b1;
best.W2 = W2;
best.b2 = b2;

epoch_num = 20;
batch_size = 200;
its_per_epoch = N / batch_size;
num_iters = epoch_num * its_per_epoch;
step_size = 1e-4;   % learning rate
step_size_decay = 0.95;

step_cache{1} = zeros(size(W1));
step_cache{2} = zeros(size(b1));
step_cache{3} = zeros(size(W2));
step_cache{4} = zeros(size(b2));

val_acc_history = zeros(num_iters, 1);
loss_history = zeros(num_iters, 1);


% X_batch = X_val;
% y_batch = y_val;

% batch_mask = randi(N, batch_size, 1);
% X_batch = X(:, :, :, batch_mask);
% y_batch = y_tr(batch_mask);

for i = 1:num_iters
    %% sample one batch examples.
    batch_mask = randi(N, batch_size, 1);
    X_batch = X(:, :, :, batch_mask);
    y_batch = y_tr(batch_mask);
    
    % forward pass.
    [a, cache] = conv_relu_pool_forward(X_batch, W1, b1, conv_param, pool_param);
    X_cols = cache{1};
    X_conv = cache{2};
    X_relu = cache{3};
    X_pool = cache{4};
    max_ind = cache{5};
    
    % fully affine
    [scores, X_affine] = affine_forward(a, W2, b2);
        
    % back prop
    [loss, dscores] = softmax_loss(scores, y_batch);
    loss_history(i) = loss;
    % test parameters on validation data
    %     acc = predict(X_val, y_val, W1, b1, W2, b2, conv_param, pool_param);
    
%     acc = predict(scores, y_batch);
    acc = predict(X_val, y_val, W1, b1, W2, b2, conv_param, pool_param);
    val_acc_history(i) = acc;
    fprintf('#%d: loss: %f | accuracy: %f | bestloss: %f | best_acc: %f\n', i, loss, acc, best.loss, best_acc)
    if loss < best.loss
        fprintf('bingo!\n')
        best.loss = loss;
%         best.W1 = W1;
%         best.b1 = b1;
%         best.W2 = W2;
%         best.b2 = b2;
    end
    
    if acc > best_acc
        fprintf(' Yes!\n')
        best_acc = acc;
    end
    
    
    % back pass affine layer
    % checked!
    [dX_affine, dW2, db2] = affine_backward(X_affine, dscores, W2);
    
    % back pass reshape layer
    % checked!
    dX_pool = reshape(dX_affine, size(X_pool));
    
    % back pass pooling layer
    % checked!
    % Note.  when gradient_check dX_relu, need to choose those !=0 values as check_ind.
    dX_relu = max_pool_backward(X_pool, dX_pool, max_ind, pool_param);
    
    % back pass ReLU layer
    dX_conv = relu_backward(dX_relu, X_conv);
    
    % back pass Conv layer
    [dW1, db1] = conv_backward(X_cols, dX_conv, W1);
    
    %% update the weights.
    step_cache{1} = step_cache{1} * 0.95 - dW1 * step_size;
    step_cache{2} = step_cache{2} * 0.95 - db1 * step_size;
    step_cache{3} = step_cache{3} * 0.95 - dW2 * step_size;
    step_cache{4} = step_cache{4} * 0.95 - db2 * step_size;
    W1 = W1 + step_cache{1};
    b1 = b1 + step_cache{2};
    W2 = W2 + step_cache{3};
    b2 = b2 + step_cache{4};
    
    if mod(i, its_per_epoch) == 0
        step_size = step_size * step_size_decay;
    end
end




% % forward pass.
% [a, cache] = conv_relu_pool_forward(X_batch, W1, b1, conv_param, pool_param);
% X_cols = cache{1};
% X_conv = cache{2};
% X_relu = cache{3};
% X_pool = cache{4};
% 
% % fully affine
% [scores, X_affine] = affine_forward(a, W2, b2);
%  
% % back prop
% [loss, dscores] = softmax_loss(scores, y_batch);
% 
% % back pass affine layer
% % checked!
% [dX_affine, dW2, db2] = affine_backward(X_affine, dscores, W2);
% 
% % back pass reshape layer
% % checked!
% dX_pool = reshape(dX_affine, size(X_pool));
% 
% % back pass pooling layer
% % checked!
% % Note.  when gradient_check dX_relu, need to choose those !=0 values as check_ind.
% dX_relu = max_pool_backward(X_relu, X_pool, dX_pool, pool_param);
% 
% % back pass ReLU layer
% dX_conv = relu_backward(dX_relu, X_conv);
% 
% % back pass Conv layer
% [dW1, db1] = conv_backward(X_cols, dX_conv, W1);
% 
% % update parameters























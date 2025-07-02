TITLE: Running the MLP Training Loop (Python)
DESCRIPTION: Instantiates the MLP model and SGD optimizer. It then runs the training loop for a specified number of epochs, iterating through minibatches, computing loss and gradients, updating model parameters, and evaluating accuracy on the test set after each epoch.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/examples/mlp.rst#_snippet_6

LANGUAGE: python
CODE:
```
# Load the model
model = MLP(num_layers, train_images.shape[-1], hidden_dim, num_classes)
mx.eval(model.parameters())

# Get a function which gives the loss and gradient of the
# loss with respect to the model's trainable parameters
loss_and_grad_fn = nn.value_and_grad(model, loss_fn)

# Instantiate the optimizer
optimizer = optim.SGD(learning_rate=learning_rate)

for e in range(num_epochs):
    for X, y in batch_iterate(batch_size, train_images, train_labels):
        loss, grads = loss_and_grad_fn(model, X, y)

        # Update the optimizer state and model parameters
        # in a single call
        optimizer.update(model, grads)

        # Force a graph evaluation
        mx.eval(model.parameters(), optimizer.state)

    accuracy = eval_fn(model, test_images, test_labels)
    print(f"Epoch {e}: Test accuracy {accuracy.item():.3f}")
```

----------------------------------------

TITLE: Implementing All-Reduce Gradients in MLX Python
DESCRIPTION: This snippet shows how to implement an all-reduce operation for gradients in MLX using `mx.distributed.all_sum` and `mlx.utils.tree_map`. It defines a helper function `all_reduce_grads` and integrates it into a training `step` function to average gradients across distributed processes before updating the model.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/usage/distributed.rst#_snippet_7

LANGUAGE: python
CODE:
```
from mlx.utils import tree_map

def all_reduce_grads(grads):
    N = mx.distributed.init().size()
    if N == 1:
        return grads
    return tree_map(
        lambda x: mx.distributed.all_sum(x) / N,
        grads
    )

def step(model, x, y):
    loss, grads = loss_grad_fn(model, x, y)
    grads = all_reduce_grads(grads)  # <--- This line was added
    optimizer.update(model, grads)
    return loss
```

----------------------------------------

TITLE: Basic Distributed Program Initialization and All-Sum (Python)
DESCRIPTION: Initializes the MLX distributed environment, performs an all-sum operation on a tensor across all processes, and prints the process rank and the resulting summed tensor. This demonstrates a simple distributed computation.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/usage/distributed.rst#_snippet_0

LANGUAGE: python
CODE:
```
import mlx.core as mx

world = mx.distributed.init()
x = mx.distributed.all_sum(mx.ones(10))
print(world.rank(), x)
```

----------------------------------------

TITLE: Install MLX via pip (Shell)
DESCRIPTION: Installs the MLX library using pip from PyPI. Requires Apple silicon, native Python >= 3.9, and macOS >= 13.5.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/install.rst#_snippet_0

LANGUAGE: shell
CODE:
```
pip install mlx
```

----------------------------------------

TITLE: Creating MLX Arrays in Python
DESCRIPTION: Demonstrates importing the mlx.core library and creating basic MLX arrays with integer and floating-point data types. Shows how to inspect array shape and data type.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/usage/quick_start.rst#_snippet_0

LANGUAGE: python
CODE:
```
>> import mlx.core as mx
>> a = mx.array([1, 2, 3, 4])
>> a.shape
[4]
>> a.dtype
int32
>> b = mx.array([1.0, 2.0, 3.0, 4.0])
>> b.dtype
float32
```

----------------------------------------

TITLE: Exporting an MLX Module with Parameters - Python
DESCRIPTION: Shows how to export an `mlx.nn.Module` (a `Linear` layer). A wrapper function `call` is defined to invoke the module. `mx.eval(model.parameters())` ensures parameters are evaluated. `mx.export_function` saves the wrapped function and includes the module's parameters in the 'model.mlxfn' file.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/usage/export.rst#_snippet_4

LANGUAGE: python
CODE:
```
model = nn.Linear(4, 4)
mx.eval(model.parameters())

def call(x):
   return model(x)

mx.export_function("model.mlxfn", call, mx.zeros(4))
```

----------------------------------------

TITLE: Compute Gradient of Multi-Argument Function with mx.grad (Python)
DESCRIPTION: Defines a simple loss function and demonstrates computing its gradient with respect to the first argument (`w`) and then the second argument (`x`) using `mx.grad` and the `argnums` parameter.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/usage/function_transforms.rst#_snippet_2

LANGUAGE: python
CODE:
```
def loss_fn(w, x, y):
   return mx.mean(mx.square(w * x - y))

w = mx.array(1.0)
x = mx.array([0.5, -0.5])
y = mx.array([1.5, -1.5])

# Computes the gradient of loss_fn with respect to w:
grad_fn = mx.grad(loss_fn)
dloss_dw = grad_fn(w, x, y)
# Prints array(-1, dtype=float32)
print(dloss_dw)

# To get the gradient with respect to x we can do:
grad_fn = mx.grad(loss_fn, argnums=1)
dloss_dx = grad_fn(w, x, y)
# Prints array([-1, 1], dtype=float32)
print(dloss_dx)
```

----------------------------------------

TITLE: Using mlx.core.value_and_grad with Modules
DESCRIPTION: Explains a pattern for using MLX's core value_and_grad function with mlx.nn.Module instances. It shows how to pass parameters as an argument to the function being transformed and update the module's internal state using model.update(params).
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/python/nn.rst#_snippet_4

LANGUAGE: python
CODE:
```
model = ...

def f(params, other_inputs):
    model.update(params)  # <---- Necessary to make the model use the passed parameters
    return model(other_inputs)
```

----------------------------------------

TITLE: Saving and Loading MLX Optimizer State
DESCRIPTION: Illustrates how to serialize and deserialize an MLX optimizer's state. It shows creating an optimizer, performing an update, saving the state using mlx.utils.tree_flatten and mx.save_safetensors, and then loading it back using mx.load and mlx.utils.tree_unflatten.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/python/optimizers.rst#_snippet_1

LANGUAGE: python
CODE:
```
import mlx.core as mx
from mlx.utils import tree_flatten, tree_unflatten
import mlx.optimizers as optim

optimizer = optim.Adam(learning_rate=1e-2)

# Perform some updates with the optimizer
model = {"w" : mx.zeros((5, 5))}
grads = {"w" : mx.ones((5, 5))}
optimizer.update(model, grads)

# Save the state
state = tree_flatten(optimizer.state)
mx.save_safetensors("optimizer.safetensors", dict(state))

# Later on, for example when loading from a checkpoint,
# recreate the optimizer and load the state
optimizer = optim.Adam(learning_rate=1e-2)

state = tree_unflatten(list(mx.load("optimizer.safetensors").items()))
optimizer.state = state
```

----------------------------------------

TITLE: Install MLX Python Package
DESCRIPTION: Installs the MLX Python package using pip, ensuring a version greater than or equal to 0.22 is installed.
SOURCE: https://github.com/ml-explore/mlx/blob/main/examples/cmake_project/README.md#_snippet_0

LANGUAGE: bash
CODE:
```
pip install mlx>=0.22
```

----------------------------------------

TITLE: Demonstrating Gradient Issue with External Memory Modification via NumPy View
DESCRIPTION: Illustrates how modifying an MLX array's memory indirectly through a NumPy view (without MLX being aware) leads to incorrect gradient calculations.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/usage/numpy.rst#_snippet_2

LANGUAGE: python
CODE:
```
def f(x):
    x_view = np.array(x, copy=False)
    x_view[:] *= x_view # modify memory without telling mx
    return x.sum()

x = mx.array([3.0])
y, df = mx.value_and_grad(f)(x)
print("f(x) = x² =", y.item()) # 9.0
print("f'(x) = 2x !=", df.item()) # 1.0
```

----------------------------------------

TITLE: Training Loop with MLX Optimizer and Model Update
DESCRIPTION: Demonstrates a basic training loop using an MLX optimizer (SGD). It shows how to create a model, define a loss and gradient function, iterate through batches, update the model parameters using optimizer.update, and evaluate both model parameters and optimizer state with mx.eval.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/python/optimizers.rst#_snippet_0

LANGUAGE: python
CODE:
```
# Create a model
model = MLP(num_layers, train_images.shape[-1], hidden_dim, num_classes)
mx.eval(model.parameters())

# Create the gradient function and the optimizer
loss_and_grad_fn = nn.value_and_grad(model, loss_fn)
optimizer = optim.SGD(learning_rate=learning_rate)

for e in range(num_epochs):
    for X, y in batch_iterate(batch_size, train_images, train_labels):
        loss, grads = loss_and_grad_fn(model, X, y)

        # Update the model with the gradients. So far no computation has happened.
        optimizer.update(model, grads)

        # Compute the new parameters but also the optimizer state.
        mx.eval(model.parameters(), optimizer.state)
```

----------------------------------------

TITLE: Basic MLX Training Loop (Python)
DESCRIPTION: Presents a standard MLX training loop structure. It includes placeholders for model, optimizer, and dataset initialization, defines a `step` function for forward/backward pass and optimizer update, and iterates through the dataset applying the step and evaluating the results.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/usage/distributed.rst#_snippet_5

LANGUAGE: python
CODE:
```
model = ...
optimizer = ...
dataset = ...

def step(model, x, y):
    loss, grads = loss_grad_fn(model, x, y)
    optimizer.update(model, grads)
    return loss

for x, y in dataset:
    loss = step(model, x, y)
    mx.eval(loss, model.parameters())
```

----------------------------------------

TITLE: Importing MLX and Setting Up Parameters (Python)
DESCRIPTION: Imports the core MLX package and defines parameters for the linear regression problem, including dataset size, number of iterations, and learning rate.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/examples/linear_regression.rst#_snippet_0

LANGUAGE: Python
CODE:
```
import mlx.core as mx

num_features = 100
num_examples = 1_000
num_iters = 10_000  # iterations of SGD
lr = 0.01  # learning rate for SGD
```

----------------------------------------

TITLE: Evaluating MLX Graph at End of Training Loop Iteration in Python
DESCRIPTION: Demonstrates a common and efficient pattern for using `mx.eval` in an iterative process like a training loop. The forward pass, gradient computation, and optimizer update build the compute graph lazily. The evaluation is triggered once per batch iteration using `mx.eval(loss, model.parameters())`, batching significant work.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/usage/lazy_evaluation.rst#_snippet_3

LANGUAGE: python
CODE:
```
for batch in dataset:

    # Nothing has been evaluated yet
    loss, grad = value_and_grad_fn(model, batch)

    # Still nothing has been evaluated
    optimizer.update(model, grad)

    # Evaluate the loss and the new parameters which will
    # run the full gradient computation and optimizer update
    mx.eval(loss, model.parameters())
```

----------------------------------------

TITLE: Inefficient Frequent Evaluation in MLX Loop in Python
DESCRIPTION: Provides an example of inefficient use of `mx.eval` within a loop. Evaluating after every few operations (`a = a + b`, `b = b * 2`) incurs a fixed overhead for each evaluation, which is detrimental to performance. It is generally better to batch more operations before evaluating.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/usage/lazy_evaluation.rst#_snippet_2

LANGUAGE: python
CODE:
```
for _ in range(100):
     a = a + b
     mx.eval(a)
     b = b * 2
     mx.eval(b)
```

----------------------------------------

TITLE: Defining Loss Function and Gradient (Python)
DESCRIPTION: Defines the mean squared error loss function for linear regression and uses `mlx.core.grad` to automatically compute its gradient with respect to the model parameters `w`.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/examples/linear_regression.rst#_snippet_2

LANGUAGE: Python
CODE:
```
def loss_fn(w):
    return 0.5 * mx.mean(mx.square(X @ w - y))

grad_fn = mx.grad(loss_fn)
```

----------------------------------------

TITLE: Implementing Llama Attention Layer in MLX Python
DESCRIPTION: This Python class defines the Llama attention mechanism using MLX's neural network modules. It incorporates RoPE positional encoding and supports optional key/value caching for efficient inference. It uses `mlx.nn.Linear` for projections and `mlx.nn.RoPE` for positional encoding.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/examples/llama-inference.rst#_snippet_0

LANGUAGE: python
CODE:
```
import mlx.core as mx
import mlx.nn as nn

class LlamaAttention(nn.Module):
    def __init__(self, dims: int, num_heads: int):
        super().__init__()

        self.num_heads = num_heads

        self.rope = nn.RoPE(dims // num_heads, traditional=True)
        self.query_proj = nn.Linear(dims, dims, bias=False)
        self.key_proj = nn.Linear(dims, dims, bias=False)
        self.value_proj = nn.Linear(dims, dims, bias=False)
        self.out_proj = nn.Linear(dims, dims, bias=False)

    def __call__(self, queries, keys, values, mask=None, cache=None):
        queries = self.query_proj(queries)
        keys = self.key_proj(keys)
        values = self.value_proj(values)

        # Extract some shapes
        num_heads = self.num_heads
        B, L, D = queries.shape

        # Prepare the queries, keys and values for the attention computation
        queries = queries.reshape(B, L, num_heads, -1).transpose(0, 2, 1, 3)
        keys = keys.reshape(B, L, num_heads, -1).transpose(0, 2, 1, 3)
        values = values.reshape(B, L, num_heads, -1).transpose(0, 2, 1, 3)

        # Add RoPE to the queries and keys and combine them with the cache
        if cache is not None:
            key_cache, value_cache = cache
            queries = self.rope(queries, offset=key_cache.shape[2])
            keys = self.rope(keys, offset=key_cache.shape[2])
            keys = mx.concatenate([key_cache, keys], axis=2)
            values = mx.concatenate([value_cache, values], axis=2)
        else:
            queries = self.rope(queries)
            keys = self.rope(keys)

        # Finally perform the attention computation
        scale = math.sqrt(1 / queries.shape[-1])
        scores = (queries * scale) @ keys.transpose(0, 1, 3, 2)
        if mask is not None:
            scores = scores + mask
        scores = mx.softmax(scores, axis=-1)
        values_hat = (scores @ values).transpose(0, 2, 1, 3).reshape(B, L, -1)

        # Note that we return the keys and values to possibly be used as a cache
        return self.out_proj(values_hat), (keys, values)
```

----------------------------------------

TITLE: Defining a Batch Iterator for Training Data (Python)
DESCRIPTION: Defines a generator function `batch_iterate` that yields shuffled minibatches of input data `X` and labels `y` for training. It uses NumPy for shuffling and MLX arrays for indexing.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/examples/mlp.rst#_snippet_5

LANGUAGE: python
CODE:
```
def batch_iterate(batch_size, X, y):
    perm = mx.array(np.random.permutation(y.size))
    for s in range(0, y.size, batch_size):
        ids = perm[s : s + batch_size]
        yield X[ids], y[ids]
```

----------------------------------------

TITLE: Managing Dependencies Across Devices (MLX Python)
DESCRIPTION: Illustrates how MLX automatically handles dependencies between operations running on different devices (CPU and GPU) by scheduling the second operation to wait for the first's completion.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/usage/unified_memory.rst#_snippet_2

LANGUAGE: python
CODE:
```
c = mx.add(a, b, stream=mx.cpu)
d = mx.add(a, c, stream=mx.gpu)
```

----------------------------------------

TITLE: Example Llama Model Initialization and Generation (MLX Python)
DESCRIPTION: Demonstrates how to initialize a small Llama model, materialize its parameters using `mx.eval`, define a prompt as an MLX array, and use the `generate` method to produce a sequence of tokens. It highlights MLX's lazy evaluation and how computation is deferred until `mx.eval` is called.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/examples/llama-inference.rst#_snippet_5

LANGUAGE: python
CODE:
```
model = Llama(num_layers=12, vocab_size=8192, dims=512, mlp_dims=1024, num_heads=8)

    # Since MLX is lazily evaluated nothing has actually been materialized yet.
    # We could have set the `dims` to 20_000 on a machine with 8GB of RAM and the
    # code above would still run. Let's actually materialize the model.
    mx.eval(model.parameters())

    prompt = mx.array([[1, 10, 8, 32, 44, 7]])  # <-- Note the double brackets because we
                                                #     have a batch dimension even
                                                #     though it is 1 in this case

    generated = [t for i, t in zip(range(10), model.generate(prompt, 0.8))]

    # Since we haven't evaluated anything, nothing is computed yet. The list
    # `generated` contains the arrays that hold the computation graph for the
    # full processing of the prompt and the generation of 10 tokens.
    #
    # We can evaluate them one at a time, or all together. Concatenate them or
    # print them. They would all result in very similar runtimes and give exactly
    # the same results.
    mx.eval(generated)
```

----------------------------------------

TITLE: MLX Compiling Training Step with State Capture
DESCRIPTION: Demonstrates how to compile a full training step (forward pass, backward pass, and optimizer update) using `mlx.compile`. It shows how to capture the model and optimizer states as both inputs and outputs to the compiled function, allowing the state to be updated efficiently within the compiled graph.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/usage/compile.rst#_snippet_13

LANGUAGE: python
CODE:
```
import mlx.core as mx
import mlx.nn as nn
import mlx.optimizers as optim
from functools import partial

# 4 examples with 10 features each
x = mx.random.uniform(shape=(4, 10))

# 0, 1 targets
y = mx.array([0, 1, 0, 1])

# Simple linear model
model = nn.Linear(10, 1)

# SGD with momentum
optimizer = optim.SGD(learning_rate=0.1, momentum=0.8)

def loss_fn(model, x, y):
    logits = model(x).squeeze()
    return nn.losses.binary_cross_entropy(logits, y)

# The state that will be captured as input and output
state = [model.state, optimizer.state]

@partial(mx.compile, inputs=state, outputs=state)
def step(x, y):
    loss_and_grad_fn = nn.value_and_grad(model, loss_fn)
    loss, grads = loss_and_grad_fn(model, x, y)
    optimizer.update(model, grads)
    return loss

# Perform 10 steps of gradient descent
for it in range(10):
    loss = step(x, y)
    # Evaluate the model and optimizer state
    mx.eval(state)
    print(loss)
```

----------------------------------------

TITLE: Implementing Full Llama Model in MLX Python
DESCRIPTION: This Python class represents the complete Llama model architecture in MLX. It consists of an embedding layer (`mlx.nn.Embedding`), a sequence of `LlamaEncoderLayer` instances, a final RMS normalization layer, and an output projection layer (`mlx.nn.Linear`). It combines these components to process input tokens.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/examples/llama-inference.rst#_snippet_2

LANGUAGE: python
CODE:
```
class Llama(nn.Module):
    def __init__(
        self, num_layers: int, vocab_size: int, dims: int, mlp_dims: int, num_heads: int
    ):
        super().__init__()

        self.embedding = nn.Embedding(vocab_size, dims)
        self.layers = [
            LlamaEncoderLayer(dims, mlp_dims, num_heads) for _ in range(num_layers)
        ]
        self.norm = nn.RMSNorm(dims)
        self.out_proj = nn.Linear(dims, vocab_size, bias=False)
```

----------------------------------------

TITLE: Evaluating MLX Arrays in Python
DESCRIPTION: Illustrates the lazy evaluation nature of MLX operations. Shows how to explicitly evaluate an array using `mx.eval()`, and how printing or converting to a NumPy array also triggers evaluation.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/usage/quick_start.rst#_snippet_1

LANGUAGE: python
CODE:
```
>> c = a + b    # c not yet evaluated
>> mx.eval(c)  # evaluates c
>> c = a + b
>> print(c)     # Also evaluates c
array([2, 4, 6, 8], dtype=float32)
>> c = a + b
>> import numpy as np
>> np.array(c)   # Also evaluates c
array([2., 4., 6., 8.], dtype=float32)
```

----------------------------------------

TITLE: Defining Function with Unused Computation in MLX Python
DESCRIPTION: Defines a Python function `fun` that includes a call to `expensive_fun`. Demonstrates that if the output of `expensive_fun` is not used (e.g., assigned to `_`), the computation is skipped due to MLX's lazy evaluation. Highlights that the graph is still built, incurring some overhead.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/usage/lazy_evaluation.rst#_snippet_0

LANGUAGE: python
CODE:
```
def fun(x):
    a = fun1(x)
    b = expensive_fun(a)
    return a, b

y, _ = fun(x)
```

----------------------------------------

TITLE: Creating a Simple MLX C++ Program (C++)
DESCRIPTION: Defines a basic C++ program (`example.cpp`) that includes the MLX header, uses the `mlx::core` namespace, creates two MLX arrays, adds them, and prints the result to standard output. Requires the MLX C++ library.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/dev/mlx_in_cpp.rst#_snippet_1

LANGUAGE: C++
CODE:
```
#include <iostream>

#include "mlx/mlx.h"

namespace mx = mlx::core;

int main() {
  auto x = mx::array({1, 2, 3});
  auto y = mx::array({1, 2, 3});
  std::cout << x + y << std::endl;
  return 0;
}
```

----------------------------------------

TITLE: Implementing Llama Encoder Layer in MLX Python
DESCRIPTION: This Python class implements a single encoder layer for the Llama model using MLX. It combines the custom `LlamaAttention` layer with RMS normalization (`mlx.nn.RMSNorm`) and a feed-forward network using SwiGLU activation. It processes input `x` and optionally uses a cache for attention.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/examples/llama-inference.rst#_snippet_1

LANGUAGE: python
CODE:
```
class LlamaEncoderLayer(nn.Module):
    def __init__(self, dims: int, mlp_dims: int, num_heads: int):
        super().__init__()

        self.attention = LlamaAttention(dims, num_heads)

        self.norm1 = nn.RMSNorm(dims)
        self.norm2 = nn.RMSNorm(dims)

        self.linear1 = nn.Linear(dims, mlp_dims, bias=False)
        self.linear2 = nn.Linear(dims, mlp_dims, bias=False)
        self.linear3 = nn.Linear(mlp_dims, dims, bias=False)

    def __call__(self, x, mask=None, cache=None):
        y = self.norm1(x)
        y, cache = self.attention(y, y, y, mask, cache)
        x = x + y

        y = self.norm2(x)
        a = self.linear1(y)
        b = self.linear2(y)
        y = a * mx.sigmoid(a) * b
        y = self.linear3(y)
        x = x + y

        return x, cache
```

----------------------------------------

TITLE: Defining and Using an MLP in MLX
DESCRIPTION: Demonstrates how to define a simple Multi-Layer Perceptron (MLP) using mlx.nn.Module and mlx.nn.Linear. Shows how to instantiate the model, access parameters, trigger initialization via evaluation, define a loss function, and use mlx.nn.value_and_grad for automatic differentiation.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/python/nn.rst#_snippet_0

LANGUAGE: python
CODE:
```
import mlx.core as mx
import mlx.nn as nn

class MLP(nn.Module):
    def __init__(self, in_dims: int, out_dims: int):
        super().__init__()

        self.layers = [
            nn.Linear(in_dims, 128),
            nn.Linear(128, 128),
            nn.Linear(128, out_dims),
        ]

    def __call__(self, x):
        for i, l in enumerate(self.layers):
            x = mx.maximum(x, 0) if i > 0 else x
            x = l(x)
        return x

# The model is created with all its parameters but nothing is initialized
# yet because MLX is lazily evaluated
mlp = MLP(2, 10)

# We can access its parameters by calling mlp.parameters()
params = mlp.parameters()
print(params["layers"][0]["weight"].shape)

# Printing a parameter will cause it to be evaluated and thus initialized
print(params["layers"][0])

# We can also force evaluate all parameters to initialize the model
mx.eval(mlp.parameters())

# A simple loss function.
# NOTE: It doesn't matter how it uses the mlp model. It currently captures
#       it from the local scope. It could be a positional argument or a
#       keyword argument.
def l2_loss(x, y):
    y_hat = mlp(x)
    return (y_hat - y).square().mean()

# Calling `nn.value_and_grad` instead of `mx.value_and_grad` returns the
# gradient with respect to `mlp.trainable_parameters()`
loss_and_grad = nn.value_and_grad(mlp, l2_loss)
```

----------------------------------------

TITLE: MLX Simple Training Loop Without Compilation
DESCRIPTION: Provides a basic example of training a simple linear model using MLX. It sets up a model, an optimizer, a loss function, and a gradient function, then runs a loop performing forward pass, backward pass, and optimizer update steps without using `mlx.compile`.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/usage/compile.rst#_snippet_12

LANGUAGE: python
CODE:
```
import mlx.core as mx
import mlx.nn as nn
import mlx.optimizers as optim

# 4 examples with 10 features each
x = mx.random.uniform(shape=(4, 10))

# 0, 1 targets
y = mx.array([0, 1, 0, 1])

# Simple linear model
model = nn.Linear(10, 1)

# SGD with momentum
optimizer = optim.SGD(learning_rate=0.1, momentum=0.8)

def loss_fn(model, x, y):
    logits = model(x).squeeze()
    return nn.losses.binary_cross_entropy(logits, y)

loss_and_grad_fn = nn.value_and_grad(model, loss_fn)

# Perform 10 steps of gradient descent
for it in range(10):
    loss, grads = loss_and_grad_fn(model, x, y)
    optimizer.update(model, grads)
    mx.eval(model.parameters(), optimizer.state)
```

----------------------------------------

TITLE: Loading Model Weights Efficiently with MLX Lazy Evaluation in Python
DESCRIPTION: Illustrates how MLX's lazy evaluation allows instantiating a large model (`Model`) without allocating memory immediately. Memory is only consumed upon evaluation. This pattern facilitates loading lower-precision weights (e.g., float16) efficiently, potentially halving memory usage compared to eager evaluation.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/usage/lazy_evaluation.rst#_snippet_1

LANGUAGE: python
CODE:
```
model = Model() # no memory used yet
model.load_weights("weights_fp16.safetensors")
```

----------------------------------------

TITLE: Define Grid Sample VJP using MLX
DESCRIPTION: This Python function defines the Vector-Jacobian Product (VJP) for the `grid_sample` operation. It is decorated with `@grid_sample.vjp` to register it as the backward pass. It takes the primal inputs (`x`, `grid`) and the cotangent (`cotangent`) and prepares the necessary dimensions before defining the Metal kernel source code responsible for the actual gradient computation using atomic updates.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/dev/custom_metal_kernels.rst#_snippet_7

LANGUAGE: python
CODE:
```
@grid_sample.vjp
def grid_sample_vjp(primals, cotangent, _):
    x, grid = primals
    B, _, _, C = x.shape
    _, gN, gM, D = grid.shape

    assert D == 2, "Last dim of `grid` must be size 2."

    source = """
        uint elem = thread_position_in_grid.x;
        int H = x_shape[1];
        int W = x_shape[2];
        int C = x_shape[3];
        // Pad C to the nearest larger simdgroup size multiple
        int C_padded = ceildiv(C, threads_per_simdgroup) * threads_per_simdgroup;

        int gH = grid_shape[1];
        int gW = grid_shape[2];

        int w_stride = C;
        int h_stride = W * w_stride;
        int b_stride = H * h_stride;

        uint grid_idx = elem / C_padded * 2;
        float ix = ((grid[grid_idx] + 1) * W - 1) / 2;
        float iy = ((grid[grid_idx + 1] + 1) * H - 1) / 2;

        int ix_nw = floor(ix);
        int iy_nw = floor(iy);

        int ix_ne = ix_nw + 1;
        int iy_ne = iy_nw;

        int ix_sw = ix_nw;
        int iy_sw = iy_nw + 1;

        int ix_se = ix_nw + 1;
        int iy_se = iy_nw + 1;

        T nw = (ix_se - ix)    * (iy_se - iy);
        T ne = (ix    - ix_sw) * (iy_sw - iy);
        T sw = (ix_ne - ix)    * (iy    - iy_ne);
        T se = (ix    - ix_nw) * (iy    - iy_nw);

        int batch_idx = elem / C_padded / gH / gW * b_stride;
        int channel_idx = elem % C_padded;
        int base_idx = batch_idx + channel_idx;

        T gix = T(0);
        T giy = T(0);
        if (channel_idx < C) {
            int cot_index = elem / C_padded * C + channel_idx;
            T cot = cotangent[cot_index];
            if (iy_nw >= 0 && iy_nw <= H - 1 && ix_nw >= 0 && ix_nw <= W - 1) {
                int offset = base_idx + iy_nw * h_stride + ix_nw * w_stride;
                atomic_fetch_add_explicit(&x_grad[offset], nw * cot, memory_order_relaxed);

                T I_nw = x[offset];
                gix -= I_nw * (iy_se - iy) * cot;
                giy -= I_nw * (ix_se - ix) * cot;
            }
            if (iy_ne >= 0 && iy_ne <= H - 1 && ix_ne >= 0 && ix_ne <= W - 1) {
                int offset = base_idx + iy_ne * h_stride + ix_ne * w_stride;
                atomic_fetch_add_explicit(&x_grad[offset], ne * cot, memory_order_relaxed);

                T I_ne = x[offset];
                gix += I_ne * (iy_sw - iy) * cot;
                giy -= I_ne * (ix - ix_sw) * cot;
            }
            if (iy_sw >= 0 && iy_sw <= H - 1 && ix_sw >= 0 && ix_sw <= W - 1) {
                int offset = base_idx + iy_sw * h_stride + ix_sw * w_stride;
                atomic_fetch_add_explicit(&x_grad[offset], sw * cot, memory_order_relaxed);

                T I_sw = x[offset];
                gix -= I_sw * (iy - iy_ne) * cot;
                giy += I_sw * (ix_ne - ix) * cot;
            }
            if (iy_se >= 0 && iy_se <= H - 1 && ix_se >= 0 && ix_se <= W - 1) {
                int offset = base_idx + iy_se * h_stride + ix_se * w_stride;
                atomic_fetch_add_explicit(&x_grad[offset], se * cot, memory_order_relaxed);

                T I_se = x[offset];
                gix += I_se * (iy - iy_nw) * cot;
                giy += I_se * (ix - ix_nw) * cot;
            }
        }

        T gix_mult = W / 2;
        T giy_mult = H / 2;

        // Reduce across each simdgroup first.
        // This is much faster than relying purely on atomics.
        gix = simd_sum(gix);
        giy = simd_sum(giy);

        if (thread_index_in_simdgroup == 0) {
            atomic_fetch_add_explicit(&grid_grad[grid_idx], gix * gix_mult, memory_order_relaxed);
            atomic_fetch_add_explicit(&grid_grad[grid_idx + 1], giy * giy_mult, memory_order_relaxed);
        }
    """
    # The actual call to mx.fast.metal_kernel would follow here, using the 'source' string.
    # For example:
    # return mx.fast.metal_kernel(
    #     source,
    #     [x, grid, cotangent],
    #     [x.shape, grid.shape],
    #     [x.dtype, grid.dtype, cotangent.dtype],
    #     [x.shape, grid.shape], # Output shapes for x_grad, grid_grad
    #     [x.dtype, grid.dtype], # Output dtypes for x_grad, grid_grad
    #     init_value=0,
    #     atomic_outputs=True
    # )
    # Note: The return statement is commented out as it was not in the provided snippet.
    pass # Placeholder as the return was not in the snippet
```

----------------------------------------

TITLE: Autoregressive Token Generation (MLX Python)
DESCRIPTION: Implements an autoregressive token generation method for the Llama model as a Python generator. It processes the initial prompt, caches layer states, yields the first generated token, and then enters a loop to generate subsequent tokens one by one, updating the cache at each step. It uses a temperature parameter for sampling.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/examples/llama-inference.rst#_snippet_4

LANGUAGE: python
CODE:
```
class Llama(nn.Module):
        ...

        def generate(self, x, temp=1.0):
            cache = []

            # Make an additive causal mask. We will need that to process the prompt.
            mask = nn.MultiHeadAttention.create_additive_causal_mask(x.shape[1])
            mask = mask.astype(self.embedding.weight.dtype)

            # First we process the prompt x the same way as in __call__ but
            # save the caches in cache
            x = self.embedding(x)
            for l in self.layers:
                x, c = l(x, mask=mask)
                cache.append(c)  # <--- we store the per layer cache in a
                                 #      simple python list
            x = self.norm(x)
            y = self.out_proj(x[:, -1])  # <--- we only care about the last logits
                                         #      that generate the next token
            y = mx.random.categorical(y * (1/temp))

            # y now has size [1]
            # Since MLX is lazily evaluated nothing is computed yet.
            # Calling y.item() would force the computation to happen at
            # this point but we can also choose not to do that and let the
            # user choose when to start the computation.
            yield y

            # Now we parsed the prompt and generated the first token we
            # need to feed it back into the model and loop to generate the
            # rest.
            while True:
                # Unsqueezing the last dimension to add a sequence length
                # dimension of 1
                x = y[:, None]

                x = self.embedding(x)
                for i in range(len(cache)):
                    # We are overwriting the arrays in the cache list. When
                    # the computation will happen, MLX will be discarding the
                    # old cache the moment it is not needed anymore.
                    x, cache[i] = self.layers[i](x, mask=None, cache=cache[i])
                x = self.norm(x)
                y = self.out_proj(x[:, -1])
                y = mx.random.categorical(y * (1/temp))

                yield y
```

----------------------------------------

TITLE: Running Llama Weight Conversion and Inference (Bash)
DESCRIPTION: Provides example command-line usage for converting PyTorch Llama weights to the MLX format using `convert.py` and then running text generation inference with the converted weights and a tokenizer using `llama.py`. Includes example output and timing information.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/examples/llama-inference.rst#_snippet_8

LANGUAGE: bash
CODE:
```
$ python convert.py weights.pth llama-7B.mlx.npz
$ python llama.py llama-7B.mlx.npz tokenizer.model 'Call me Ishmael. Some years ago never mind how long precisely'
[INFO] Loading model from disk: 5.247 s
Press enter to start generation
------
, having little or no money in my purse, and nothing of greater consequence in my mind, I happened to be walking down Gower Street in the afternoon, in the heavy rain, and I saw a few steps off, a man in rags, who sat upon his bundle and looked hard into the wet as if he were going to cry. I watched him attentively for some time, and could not but observe that, though a numerous crowd was hurrying up and down,
------
[INFO] Prompt processing: 0.437 s
[INFO] Full generation: 4.330 s
```

----------------------------------------

TITLE: Loading MLX Weights with tree_unflatten (Python)
DESCRIPTION: Demonstrates how to load weights from an NPZ file using `mlx.core.load` and then restructure the flat key-value pairs into a nested dictionary suitable for updating an MLX model using `mlx.utils.tree_unflatten`. This method involves intermediate copies.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/examples/llama-inference.rst#_snippet_7

LANGUAGE: python
CODE:
```
from mlx.utils import tree_unflatten

model.update(tree_unflatten(list(mx.load(weight_file).items())))
```

----------------------------------------

TITLE: Performing SGD Optimization (Python)
DESCRIPTION: Initializes the model parameters `w` randomly and performs Stochastic Gradient Descent (SGD) for a fixed number of iterations, updating `w` using the computed gradient and learning rate. `mx.eval` is used to evaluate the updated parameters.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/examples/linear_regression.rst#_snippet_3

LANGUAGE: Python
CODE:
```
w = 1e-2 * mx.random.normal((num_features,))

for _ in range(num_iters):
    grad = grad_fn(w)
    w = w - lr * grad
    mx.eval(w)
```

----------------------------------------

TITLE: Using Shapeless Compilation in MLX Python
DESCRIPTION: Shows how to use `mx.compile` with `shapeless=True` to prevent recompilation when input shapes change. The example defines a simple function and calls the compiled version with different input shapes without triggering recompilation. Requires the `mlx.core` library.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/usage/compile.rst#_snippet_16

LANGUAGE: python
CODE:
```
def fun(x, y):
    return mx.abs(x + y)

compiled_fun = mx.compile(fun, shapeless=True)

x = mx.array(1.0)
y = mx.array(-2.0)

# Firt call compiles the function
print(compiled_fun(x, y))

# Second call with different shapes
# does not recompile the function
x = mx.array([1.0, -6.0])
y = mx.array([-2.0, 3.0])
print(compiled_fun(x, y))
```

----------------------------------------

TITLE: Build and install Python API from source (Shell)
DESCRIPTION: Builds and installs the MLX Python API from the local source directory using pip. Sets the parallel build level for CMake.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/install.rst#_snippet_4

LANGUAGE: shell
CODE:
```
CMAKE_BUILD_PARALLEL_LEVEL=8 pip install .
```

----------------------------------------

TITLE: Using mlx.nn.average_gradients for Efficient All-Reduce in MLX Python
DESCRIPTION: This snippet demonstrates the more efficient way to perform gradient averaging in MLX using the built-in `mlx.nn.average_gradients` function. It shows how to replace the manual `all_reduce_grads` call with this function within the training `step` and includes a basic training loop structure.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/usage/distributed.rst#_snippet_8

LANGUAGE: python
CODE:
```
model = ...
optimizer = ...
dataset = ...

def step(model, x, y):
    loss, grads = loss_grad_fn(model, x, y)
    grads = mlx.nn.average_gradients(grads) # <---- This line was added
    optimizer.update(model, grads)
    return loss

for x, y in dataset:
    loss = step(model, x, y)
    mx.eval(loss, model.parameters())
```

----------------------------------------

TITLE: Defining the Multi-Layer Perceptron Model (Python)
DESCRIPTION: Defines the MLP class inheriting from `mlx.nn.Module`. The `__init__` method sets up linear layers based on input dimensions, hidden dimensions, and number of layers. The `__call__` method implements the forward pass with ReLU activation between hidden layers.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/examples/mlp.rst#_snippet_1

LANGUAGE: python
CODE:
```
class MLP(nn.Module):
    def __init__(
        self, num_layers: int, input_dim: int, hidden_dim: int, output_dim: int
    ):
        super().__init__()
        layer_sizes = [input_dim] + [hidden_dim] * num_layers + [output_dim]
        self.layers = [
            nn.Linear(idim, odim)
            for idim, odim in zip(layer_sizes[:-1], layer_sizes[1:])
        ]

    def __call__(self, x):
        for l in self.layers[:-1]:
            x = mx.maximum(l(x), 0.0)
        return self.layers[-1](x)
```

----------------------------------------

TITLE: Partial PyTorch to MLX Weight Conversion Script (Python)
DESCRIPTION: Provides a partial Python script for converting PyTorch model weights to an MLX-compatible format (NPZ). It includes necessary imports and the beginning of a mapping function (`map_torch_to_mlx`) that handles specific key name transformations, such as renaming 'tok_embedding' to 'embedding.weight'.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/examples/llama-inference.rst#_snippet_6

LANGUAGE: python
CODE:
```
import argparse
    from itertools import starmap

    import numpy as np
    import torch

    def map_torch_to_mlx(key, value):
        if "tok_embedding" in key:
            key = "embedding.weight"
```

----------------------------------------

TITLE: Compiling a Simple MLX Function - Python
DESCRIPTION: Defines a simple function, creates MLX arrays, and demonstrates calling the function both directly and after compilation using `mx.compile`. Shows that the output is the same but compilation provides performance benefits on subsequent calls.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/usage/compile.rst#_snippet_0

LANGUAGE: python
CODE:
```
def fun(x, y):
    return mx.exp(-x) + y

x = mx.array(1.0)
y = mx.array(2.0)

# Regular call, no compilation
# Prints: array(2.36788, dtype=float32)
print(fun(x, y))

# Compile the function
compiled_fun = mx.compile(fun)

# Prints: array(2.36788, dtype=float32)
print(compiled_fun(x, y))
```

----------------------------------------

TITLE: Compiling a Transformed Function (Gradient) in MLX Python
DESCRIPTION: Demonstrates compiling a function obtained from a transformation (`mx.grad`). It shows that both the original transformed function and the compiled version produce the same output for a given input. Requires the `mlx.core` library.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/usage/compile.rst#_snippet_14

LANGUAGE: python
CODE:
```
grad_fn = mx.grad(mx.exp)

compiled_grad_fn = mx.compile(grad_fn)

# Prints: array(2.71828, dtype=float32)
print(grad_fn(mx.array(1.0)))

# Also prints: array(2.71828, dtype=float32)
print(compiled_grad_fn(mx.array(1.0)))
```

----------------------------------------

TITLE: Run MLX Llama Model with Custom Token Limit (Bash)
DESCRIPTION: Executes the `llama.py` script to run an MLX-optimized Llama model for text generation, specifying a maximum number of tokens to generate using the `--num-tokens` argument. It loads the specified model and tokenizer files and provides an initial prompt.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/examples/llama-inference.rst#_snippet_10

LANGUAGE: bash
CODE:
```
python llama.py --num-tokens 500 llama-7B.mlx.npz tokenizer.model 'Call me Ishmael. Some years ago never mind how long precisely, having little or no money in my purse, and nothing of greater consequence in my mind, I happened to be walking down Gower Street in the afternoon, in the heavy rain, and I saw a few steps off, a man in rags, who sat upon his bundle and looked hard into the wet as if he were going to cry. I watched him attentively for some time, and could not but observe that, though a numerous crowd was hurrying up and down, nobody took the least notice of him. I stopped at last, at a little distance, as if I had been in doubt, and after looking on a few minutes, walked straight up to him. He slowly raised his eyes, and fixed them upon me for a moment, without speaking, and then resumed his place and posture as before. I stood looking at him for a while, feeling very much pain at heart, and then said to him, “What are you doing there?” Something like a smile passed over his face, as he said slowly, “I am waiting for someone; but it has been three quarters of an hour now, and he has not come.” “What is it you are waiting for?” said I. Still he made no immediate reply, but again put his face down upon his hands, and did not'
```

----------------------------------------

TITLE: Forward Pass with Causal Mask (MLX Python)
DESCRIPTION: Implements the forward pass of the Llama model for training. It applies a causal mask, processes the input through embedding and layers, normalizes the output, and applies the final projection. Note that this method is not suitable for inference due to lack of caching and sampling.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/examples/llama-inference.rst#_snippet_3

LANGUAGE: python
CODE:
```
def __call__(self, x):
            mask = nn.MultiHeadAttention.create_additive_causal_mask(x.shape[1])
            mask = mask.astype(self.embedding.weight.dtype)

            x = self.embedding(x)
            for l in self.layers:
                x, _ = l(x, mask)
            x = self.norm(x)
            return self.out_proj(x)
```

----------------------------------------

TITLE: Saving a single MLX array (Python)
DESCRIPTION: Demonstrates how to create a single MLX array and save it to a file using `mx.save`. The file extension `.npy` is automatically added if omitted.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/usage/saving_and_loading.rst#_snippet_0

LANGUAGE: shell
CODE:
```
>>> a = mx.array([1.0])
>>> mx.save("array", a)
```

----------------------------------------

TITLE: Install MLX via conda (Shell)
DESCRIPTION: Installs the MLX library using conda from the conda-forge channel.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/install.rst#_snippet_1

LANGUAGE: shell
CODE:
```
conda install conda-forge::mlx
```

----------------------------------------

TITLE: Basic Array Indexing in MLX (Shell)
DESCRIPTION: Demonstrates basic integer, negative, and slice indexing on a 1D MLX array using the shell.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/usage/indexing.rst#_snippet_0

LANGUAGE: shell
CODE:
```
>>> arr = mx.arange(10)
>>> arr[3]
array(3, dtype=int32)
>>> arr[-2]  # negative indexing works
array(8, dtype=int32)
>>> arr[2:8:2] # start, stop, stride
array([2, 4, 6], dtype=int32)
```

----------------------------------------

TITLE: Compute Second Derivative with Composed mx.grad (Shell)
DESCRIPTION: Shows how to compute the second derivative by applying `mx.grad` twice, evaluating it at pi/2, and comparing to `mx.sin(pi/2)`.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/usage/function_transforms.rst#_snippet_1

LANGUAGE: shell
CODE:
```
>>> d2fdx2 = mx.grad(mx.grad(mx.sin))
>>> d2fdx2(mx.array(mx.pi / 2))
array(-1, dtype=float32)
>>> mx.sin(mx.array(mx.pi / 2))
array(1, dtype=float32)
```

----------------------------------------

TITLE: Compute Value and Gradient with mx.value_and_grad (Python)
DESCRIPTION: Shows how to use `mx.value_and_grad` to compute both the function's output and its gradient in a single call, avoiding redundant computation compared to calling the function and `mx.grad` separately.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/usage/function_transforms.rst#_snippet_3

LANGUAGE: python
CODE:
```
# Computes the gradient of loss_fn with respect to w:
loss_and_grad_fn = mx.value_and_grad(loss_fn)
loss, dloss_dw = loss_and_grad_fn(w, x, y)

# Prints array(1, dtype=float32)
print(loss)

# Prints array(-1, dtype=float32)
print(dloss_dw)
```

----------------------------------------

TITLE: Triggering Implicit Evaluation with Scalar Array in MLX Control Flow in Python
DESCRIPTION: Illustrates that using a scalar MLX array (`y`) directly in Python control flow statements (like `if y > 0:`) will implicitly trigger an evaluation of the graph required to compute the scalar value. While functional, this can be inefficient if done frequently within a larger graph.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/usage/lazy_evaluation.rst#_snippet_4

LANGUAGE: python
CODE:
```
def fun(x):
    h, y = first_layer(x)
    if y > 0:  # An evaluation is done here!
        z  = second_layer_a(h)
    else:
        z  = second_layer_b(h)
    return z
```

----------------------------------------

TITLE: Benchmarking MLX Custom vs Simple axpby (Python)
DESCRIPTION: Provides a Python script to benchmark the performance of the custom `axpby` extension against a naive MLX implementation (`simple_axpby`). It includes setup, warm-up, timed runs, and prints the average execution time for both functions.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/dev/extensions.rst#_snippet_22

LANGUAGE: python
CODE:
```
import mlx.core as mx
from mlx_sample_extensions import axpby
import time

def simple_axpby(x: mx.array, y: mx.array, alpha: float, beta: float) -> mx.array:
    return alpha * x + beta * y

M = 4096
N = 4096

x = mx.random.normal((M, N))
y = mx.random.normal((M, N))
alpha = 4.0
beta = 2.0

mx.eval(x, y)

def bench(f):
    # Warm up
    for i in range(5):
        z = f(x, y, alpha, beta)
        mx.eval(z)

    # Timed run
    s = time.time()
    for i in range(100):
        z = f(x, y, alpha, beta)
        mx.eval(z)
    e = time.time()
    return 1000 * (e - s) / 100

simple_time = bench(simple_axpby)
custom_time = bench(axpby)

print(f"Simple axpby: {simple_time:.3f} ms | Custom axpby: {custom_time:.3f} ms")
```

----------------------------------------

TITLE: Benchmarking Compiled vs. Regular GELU - Python
DESCRIPTION: Creates a large random MLX array and uses the `timeit` helper function to compare the execution speed of the standard `gelu` implementation against its compiled version (`mx.compile(nn.gelu)`), demonstrating the performance gains from compilation.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/usage/compile.rst#_snippet_4

LANGUAGE: python
CODE:
```
x = mx.random.uniform(shape=(32, 1000, 4096))
timeit(nn.gelu, x)
timeit(mx.compile(nn.gelu), x)
```

----------------------------------------

TITLE: Avoiding Explicit Distributed Checks (Python)
DESCRIPTION: Illustrates how MLX distributed operations automatically become no-ops when the group size is 1, eliminating the need for explicit checks like `if world.size() > 1:` before performing collective operations like `all_sum`.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/usage/distributed.rst#_snippet_1

LANGUAGE: python
CODE:
```
import mlx.core as mx

x = ...
world = mx.distributed.init()
# No need for the check we can simply do x = mx.distributed.all_sum(x)
if world.size() > 1:
    x = mx.distributed.all_sum(x)
```

----------------------------------------

TITLE: Pure Function Requirement: Side Effects - Python
DESCRIPTION: Demonstrates that compiled MLX functions should be pure and avoid side effects, such as modifying external state (e.g., appending to a list). Attempting to run a compiled function with side effects will result in a crash.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/usage/compile.rst#_snippet_7

LANGUAGE: python
CODE:
```
state = []

@mx.compile
def fun(x, y):
    z = x + y
    state.append(z)
    return mx.exp(z)

fun(mx.array(1.0), mx.array(2.0))
# Crash!
print(state)
```

----------------------------------------

TITLE: Debugging Issue: Printing Inside Compiled Function - Python
DESCRIPTION: Shows an example of a function decorated with `@mx.compile` that attempts to print an intermediate MLX array (`z`). This demonstrates a common debugging issue where evaluating arrays inside compiled functions causes a crash because the function is traced with placeholder inputs.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/usage/compile.rst#_snippet_5

LANGUAGE: python
CODE:
```
@mx.compile
def fun(x):
    z = -x
    print(z)  # Crash
    return mx.exp(z)

fun(mx.array(5.0))
```

----------------------------------------

TITLE: Configuring Metal Build and SDK Validation (CMake)
DESCRIPTION: This extensive block handles the configuration for building MLX with Metal support. It checks if Metal is available, enforces a minimum macOS SDK version (14.0), fetches the `metal-cpp` library, and configures include directories and links necessary Metal, Foundation, and QuartzCore frameworks to the `mlx` target. It also defines `MLX_METAL_DEBUG` if enabled.
SOURCE: https://github.com/ml-explore/mlx/blob/main/CMakeLists.txt#_snippet_8

LANGUAGE: CMake
CODE:
```
if(MLX_BUILD_METAL AND NOT METAL_LIB)
  message(STATUS "Metal not found. Unable to build GPU")
  set(MLX_BUILD_METAL OFF)
  set(MLX_METAL_DEBUG OFF)
elseif(MLX_BUILD_METAL)
  message(STATUS "Building METAL sources")

  if(MLX_METAL_DEBUG)
    add_compile_definitions(MLX_METAL_DEBUG)
  endif()

  # Throw an error if xcrun not found
  execute_process(
    COMMAND zsh "-c" "/usr/bin/xcrun -sdk macosx --show-sdk-version"
    OUTPUT_VARIABLE MACOS_SDK_VERSION COMMAND_ERROR_IS_FATAL ANY)

  if(${MACOS_SDK_VERSION} LESS 14.0)
    message(
      FATAL_ERROR
        "MLX requires macOS SDK >= 14.0 to be built with MLX_BUILD_METAL=ON")
  endif()
  message(STATUS "Building with macOS SDK version ${MACOS_SDK_VERSION}")

  set(METAL_CPP_URL
      https://developer.apple.com/metal/cpp/files/metal-cpp_macOS15_iOS18.zip)

  if(NOT CMAKE_OSX_DEPLOYMENT_TARGET STREQUAL "")
    set(XCRUN_FLAGS "-mmacosx-version-min=${CMAKE_OSX_DEPLOYMENT_TARGET}")
  endif()
  execute_process(
    COMMAND
      zsh "-c"
      "echo \"__METAL_VERSION__\" | xcrun -sdk macosx metal ${XCRUN_FLAGS} -E -x metal -P - | tail -1 | tr -d '\n'"
    OUTPUT_VARIABLE MLX_METAL_VERSION COMMAND_ERROR_IS_FATAL ANY)
  FetchContent_Declare(metal_cpp URL ${METAL_CPP_URL})

  FetchContent_MakeAvailable(metal_cpp)
  target_include_directories(
    mlx PUBLIC $<BUILD_INTERFACE:${metal_cpp_SOURCE_DIR}>
               $<INSTALL_INTERFACE:include/metal_cpp>)
  target_link_libraries(mlx PUBLIC ${METAL_LIB} ${FOUNDATION_LIB} ${QUARTZ_LIB})
endif()
```

----------------------------------------

TITLE: Timing Naive vs. MLX vmap Performance (Python)
DESCRIPTION: Uses the `timeit` module to measure the execution time of both the naive list comprehension approach and the `mlx.core.vmap` approach for the addition operation, evaluating the MLX operations with `mx.eval`.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/usage/function_transforms.rst#_snippet_7

LANGUAGE: python
CODE:
```
import timeit

print(timeit.timeit(lambda: mx.eval(naive_add(xs, ys)), number=100))
print(timeit.timeit(lambda: mx.eval(vmap_add(xs, ys)), number=100))
```

----------------------------------------

TITLE: Defining Python Bindings for C++ Function (C++)
DESCRIPTION: This C++ snippet uses nanobind to create a Python module '_ext' and expose the 'axpby' function. It includes docstrings and argument annotations for the Python API.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/dev/extensions.rst#_snippet_15

LANGUAGE: C++
CODE:
```
NB_MODULE(_ext, m) {
    m.doc() = "Sample extension for MLX";

    m.def(
        "axpby",
        &axpby,
        "x"_a,
        "y"_a,
        "alpha"_a,
        "beta"_a,
        nb::kw_only(),
        "stream"_a = nb::none(),
        R"(
            Scale and sum two vectors element-wise
            ``z = alpha * x + beta * y``

            Follows numpy style broadcasting between ``x`` and ``y``
            Inputs are upcasted to floats if needed

            Args:
                x (array): Input array.
                y (array): Input array.
                alpha (float): Scaling factor for ``x``.
                beta (float): Scaling factor for ``y``.

            Returns:
                array: ``alpha * x + beta * y``
        )");
}
```

----------------------------------------

TITLE: Using MLX Sample Extension axpby (Python)
DESCRIPTION: Demonstrates how to import and use the custom `axpby` operation from the `mlx_sample_extensions` package. It initializes MLX arrays and calls the `axpby` function, then prints the shape, dtype, and verifies the result.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/dev/extensions.rst#_snippet_20

LANGUAGE: python
CODE:
```
import mlx.core as mx
from mlx_sample_extensions import axpby

a = mx.ones((3, 4))
b = mx.ones((3, 4))
c = axpby(a, b, 4.0, 2.0, stream=mx.cpu)

print(f"c shape: {c.shape}")
print(f"c dtype: {c.dtype}")
print(f"c is correct: {mx.all(c == 6.0).item()}")
```

----------------------------------------

TITLE: Exporting a Simple MLX Function - Python
DESCRIPTION: Defines a basic Python function `fun` for addition. It creates two scalar MLX arrays and uses `mx.export_function` to save the function to 'add.mlxfn', using the arrays as example inputs to capture the required input signature (float32 scalar).
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/usage/export.rst#_snippet_0

LANGUAGE: python
CODE:
```
def fun(x, y):
  return x + y

x = mx.array(1.0)
y = mx.array(1.0)
mx.export_function("add.mlxfn", fun, x, y)
```

----------------------------------------

TITLE: Example Pattern for Value and Gradient Computation (Python)
DESCRIPTION: This snippet illustrates a common pattern used when computing the value and gradients of a function with respect to a model's trainable parameters, often simplified by `mlx.nn.value_and_grad`. It shows calling a function `f` with the model's trainable parameters and another tensor.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/python/nn.rst#_snippet_5

LANGUAGE: Python
CODE:
```
f(model.trainable_parameters(), mx.zeros((10,)))
```

----------------------------------------

TITLE: Compute Gradient for Nested Parameters with mx.grad (Python)
DESCRIPTION: Demonstrates computing the gradient of a loss function where parameters are stored in a dictionary, showing that `mx.grad` preserves the structure of the parameters in the returned gradients.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/usage/function_transforms.rst#_snippet_4

LANGUAGE: python
CODE:
```
def loss_fn(params, x, y):
   w, b = params["weight"], params["bias"]
   h = w * x + b
   return mx.mean(mx.square(h - y))

params = {"weight": mx.array(1.0), "bias": mx.array(0.0)}
x = mx.array([0.5, -0.5])
y = mx.array([1.5, -1.5])

# Computes the gradient of loss_fn with respect to both the
# weight and bias:
grad_fn = mx.grad(loss_fn)
grads = grad_fn(params, x, y)

# Prints
# {'weight': array(-1, dtype=float32), 'bias': array(0, dtype=float32)}
print(grads)
```

----------------------------------------

TITLE: Example JSON Hostfile for MLX Distributed Launch
DESCRIPTION: Provides an example of the JSON format required for a hostfile used with `mlx.launch`. It defines a list of hosts, each with an SSH hostname and a list of IP addresses for communication.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/usage/launching_distributed.rst#_snippet_2

LANGUAGE: json
CODE:
```
[
    {"ssh": "hostname1", "ips": ["123.123.1.1", "123.123.2.1"]},
    {"ssh": "hostname2", "ips": ["123.123.1.2", "123.123.2.2"]}
]
```

----------------------------------------

TITLE: Run MLX Llama Model with Default Tokens (Bash)
DESCRIPTION: Executes the `llama.py` script to run an MLX-optimized Llama model for text generation. It loads the specified model and tokenizer files and provides an initial prompt. The script will generate text until a stop condition is met (e.g., end of sequence token or default token limit).
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/examples/llama-inference.rst#_snippet_9

LANGUAGE: bash
CODE:
```
python llama.py llama-7B.mlx.npz tokenizer.model 'Call me Ishmael. Some years ago never mind how long precisely, having little or no money in my purse, and nothing of greater consequence in my mind, I happened to be walking down Gower Street in the afternoon, in the heavy rain, and I saw a few steps off, a man in rags, who sat upon his bundle and looked hard into the wet as if he were going to cry. I watched him attentively for some time, and could not but observe that, though a numerous crowd was hurrying up and down, nobody took the least notice of him. I stopped at last, at a little distance, as if I had been in doubt, and after looking on a few minutes, walked straight up to him. He slowly raised his eyes, and fixed them upon me for a moment, without speaking, and then resumed his place and posture as before. I stood looking at him for a while, feeling very much pain at heart, and then said to him, “What are you doing there?” Something like a smile passed over his face, as he said slowly, “I am waiting for someone; but it has been three quarters of an hour now, and he has not come.” “What is it you are waiting for?” said I. Still he made no immediate reply, but again put his face down upon his hands, and did not'
```

----------------------------------------

TITLE: Performing Operations on Different Devices (MLX Python)
DESCRIPTION: Shows how the same operation (addition) can be performed on arrays in unified memory by specifying the target device (CPU or GPU) via the `stream` argument, without data copies.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/usage/unified_memory.rst#_snippet_1

LANGUAGE: python
CODE:
```
mx.add(a, b, stream=mx.cpu)
mx.add(a, b, stream=mx.gpu)
```

----------------------------------------

TITLE: Fixing Shapeless Compilation with Shape-Independent Operations in MLX Python
DESCRIPTION: Demonstrates how to modify the function from the previous example to work correctly with shapeless compilation by using a shape-independent operation like `flatten` instead of `reshape` based on static shape. Requires the `mlx.core` library.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/usage/compile.rst#_snippet_18

LANGUAGE: python
CODE:
```
def fun(x):
    return x.flatten(0, 1)

compiled_fun = mx.compile(fun, shapeless=True)

x = mx.random.uniform(shape=(2, 3, 4))

out = compiled_fun(x)

x = mx.random.uniform(shape=(5, 5, 3))

# Ok
out = compiled_fun(x)
```

----------------------------------------

TITLE: Launching MLX Program on Specific Hosts (Shell)
DESCRIPTION: Demonstrates the basic usage of `mlx.launch` to run a Python script (`my_script.py`) on a list of specified hosts (`ip1,ip2`) using the default backend.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/usage/launching_distributed.rst#_snippet_0

LANGUAGE: shell
CODE:
```
mlx.launch --hosts ip1,ip2 my_script.py
```

----------------------------------------

TITLE: Building Metal Kernel Base Function (CMake)
DESCRIPTION: This CMake function `build_kernel_base` compiles a single Metal source file (`SRCFILE`) into an intermediate `.air` file. It configures Metal compiler flags based on debug settings, macOS deployment target, and MLX Metal version, and includes necessary header paths. It uses `add_custom_command` to define the compilation step. It depends on `xcrun` and the `metal` compiler.
SOURCE: https://github.com/ml-explore/mlx/blob/main/mlx/backend/metal/kernels/CMakeLists.txt#_snippet_1

LANGUAGE: CMake
CODE:
```
function(build_kernel_base TARGET SRCFILE DEPS)
  set(METAL_FLAGS -Wall -Wextra -fno-fast-math -Wno-c++17-extensions)
  if(MLX_METAL_DEBUG)
    set(METAL_FLAGS ${METAL_FLAGS} -gline-tables-only -frecord-sources)
  endif()
  if(NOT CMAKE_OSX_DEPLOYMENT_TARGET STREQUAL "")
    set(METAL_FLAGS ${METAL_FLAGS}
                    "-mmacosx-version-min=${CMAKE_OSX_DEPLOYMENT_TARGET}")
  endif()
  if(MLX_METAL_VERSION GREATER_EQUAL 310)
    set(VERSION_INCLUDES
        ${PROJECT_SOURCE_DIR}/mlx/backend/metal/kernels/metal_3_1)
  else()
    set(VERSION_INCLUDES
        ${PROJECT_SOURCE_DIR}/mlx/backend/metal/kernels/metal_3_0)
  endif()
  add_custom_command(
    COMMAND xcrun -sdk macosx metal ${METAL_FLAGS} -c ${SRCFILE}
            -I${PROJECT_SOURCE_DIR} -I${VERSION_INCLUDES} -o ${TARGET}.air
    DEPENDS ${SRCFILE} ${DEPS} ${BASE_HEADERS}
    OUTPUT ${TARGET}.air
    COMMENT "Building ${TARGET}.air"
    VERBATIM)
endfunction(build_kernel_base)
```

----------------------------------------

TITLE: Launching MLX Distributed Program with mpirun or mlx.launch (MPI) and DYLD_LIBRARY_PATH
DESCRIPTION: This snippet provides two ways to launch a distributed MLX program (`test.py`) using MPI, specifically addressing potential issues with finding the MPI library on macOS (Homebrew installation). It shows how to use `mpirun` directly with the `DYLD_LIBRARY_PATH` environment variable and how `mlx.launch` handles this automatically.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/usage/distributed.rst#_snippet_10

LANGUAGE: shell
CODE:
```
$ mpirun -np 2 -x DYLD_LIBRARY_PATH=/opt/homebrew/lib/ python test.py
$ # or simply
$ mlx.launch -n 2 test.py
```

----------------------------------------

TITLE: Creating Python Bindings with nanobind
DESCRIPTION: This snippet uses `nanobind_add_module` to create Python bindings for the extension, naming the module `_ext`. It configures the module with static linking, stable ABI, LTO, and specifies `bindings.cpp` as the source. It then links `_ext` privately to `mlx_ext` and conditionally adds an rpath for shared libraries.
SOURCE: https://github.com/ml-explore/mlx/blob/main/examples/extensions/CMakeLists.txt#_snippet_4

LANGUAGE: CMake
CODE:
```
# ----------------------------- Python Bindings -----------------------------
nanobind_add_module(
  _ext
  NB_STATIC
  STABLE_ABI
  LTO
  NOMINSIZE
  NB_DOMAIN
  mlx
  ${CMAKE_CURRENT_LIST_DIR}/bindings.cpp)
target_link_libraries(_ext PRIVATE mlx_ext)

if(BUILD_SHARED_LIBS)
  target_link_options(_ext PRIVATE -Wl,-rpath,@loader_path)
endif()
```

----------------------------------------

TITLE: Initializing MLX Distributed Backends (Python)
DESCRIPTION: Illustrates different ways to initialize MLX distributed backends using `mx.distributed.init`. Shows how to explicitly select 'mpi' or 'any', and how subsequent calls without arguments return the already initialized backend.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/usage/distributed.rst#_snippet_4

LANGUAGE: python
CODE:
```
# Case 1: Initialize MPI regardless if it was possible to initialize the ring backend
world = mx.distributed.init(backend="mpi")
world2 = mx.distributed.init()  # subsequent calls return the MPI backend!

# Case 2: Initialize any backend
world = mx.distributed.init(backend="any")  # equivalent to no arguments
world2 = mx.distributed.init()  # same as above

# Case 3: Initialize both backends at the same time
world_mpi = mx.distributed.init(backend="mpi")
world_ring = mx.distributed.init(backend="ring")
world_any = mx.distributed.init()  # same as MPI because it was initialized first!
```

----------------------------------------

TITLE: Defining a Function with Mixed Device Operations (MLX Python)
DESCRIPTION: Defines a Python function that performs a matrix multiplication on one device (`d1`) and a loop of exponential operations on another device (`d2`), showcasing how different parts of a computation can be assigned to different devices.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/usage/unified_memory.rst#_snippet_3

LANGUAGE: python
CODE:
```
def fun(a, b, d1, d2):
  x = mx.matmul(a, b, stream=d1)
  for _ in range(500):
      b = mx.exp(b, stream=d2)
  return x, b
```

----------------------------------------

TITLE: Importing and Running MLX Function in C++
DESCRIPTION: Illustrates how to import an MLX function previously exported from Python into a C++ program using mx::import_function and execute it with C++ mx::array inputs.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/usage/export.rst#_snippet_10

LANGUAGE: c++
CODE:
```
auto fun = mx::import_function("fun.mlxfn");

auto inputs = {mx::array(1.0), mx::array(1.0)};
auto outputs = fun(inputs);

// Prints: array(2, dtype=float32)
std::cout << outputs[0] << std::endl;
```

----------------------------------------

TITLE: Configuring MLX Project with CMake
DESCRIPTION: This CMake script configures a C++ project to use the MLX library. It sets the C++ standard, finds the Python interpreter and MLX package, and links the MLX library to `eval_mlp` and `train_mlp` executables. It's essential for building MLX-dependent C++ applications.
SOURCE: https://github.com/ml-explore/mlx/blob/main/examples/export/CMakeLists.txt#_snippet_0

LANGUAGE: CMake
CODE:
```
cmake_minimum_required(VERSION 3.27)

project(import_mlx LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(
  Python 3.9
  COMPONENTS Interpreter Development.Module
  REQUIRED)
execute_process(
  COMMAND "${Python_EXECUTABLE}" -m mlx --cmake-dir
  OUTPUT_STRIP_TRAILING_WHITESPACE
  OUTPUT_VARIABLE MLX_ROOT)
find_package(MLX CONFIG REQUIRED)

add_executable(eval_mlp eval_mlp.cpp)
target_link_libraries(eval_mlp PRIVATE mlx)

add_executable(train_mlp train_mlp.cpp)
target_link_libraries(train_mlp PRIVATE mlx)
```

----------------------------------------

TITLE: MLX Compiled Function Treating External State as Constant
DESCRIPTION: Demonstrates that if external state (like a list element) is accessed within a compiled MLX function but not passed as an input, the compiled graph captures the state's value at compile time, treating it as a constant. Subsequent changes to the external state are not reflected in the compiled function's output.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/usage/compile.rst#_snippet_10

LANGUAGE: python
CODE:
```
state = [mx.array(1.0)]

@mx.compile
def fun(x):
    return x + state[0]

# Prints array(2, dtype=float32)
print(fun(mx.array(1.0)))

# Update state
state[0] = mx.array(5.0)

# Still prints array(2, dtype=float32)
print(fun(mx.array(1.0)))
```

----------------------------------------

TITLE: MLX Compiled Function Capturing State as Input
DESCRIPTION: Explains how to use the `inputs` parameter of `mlx.compile` to make external state accessible to the compiled function. This allows the compiled function to use the current value of the external state each time it is called, reflecting updates made outside the function.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/usage/compile.rst#_snippet_11

LANGUAGE: python
CODE:
```
from functools import partial
state = [mx.array(1.0)]

# Tell compile to capture state as an input
@partial(mx.compile, inputs=state)
def fun(x):
    return x + state[0]

# Prints array(2, dtype=float32)
print(fun(mx.array(1.0)))

# Update state
state[0] = mx.array(5.0)

# Prints array(6, dtype=float32)
print(fun(mx.array(1.0)))
```

----------------------------------------

TITLE: Creating NumPy View of MLX Array (No Copy)
DESCRIPTION: Shows how to create a NumPy array that is a view of an MLX array's memory, avoiding data copying. Modifications to the view are reflected in the original MLX array.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/usage/numpy.rst#_snippet_1

LANGUAGE: python
CODE:
```
a = mx.arange(3)
a_view = np.array(a, copy=False)
print(a_view.flags.owndata) # False
a_view[0] = 1
print(a[0].item()) # 1
```

----------------------------------------

TITLE: Applying Gradient Transformations in MLX Python
DESCRIPTION: Demonstrates using the `mx.grad()` function transformation to compute the first and second derivatives of the sine function with respect to its input array.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/usage/quick_start.rst#_snippet_2

LANGUAGE: python
CODE:
```
>> x = mx.array(0.0)
>> mx.sin(x)
array(0, dtype=float32)
>> mx.grad(mx.sin)(x)
array(1, dtype=float32)
>> mx.grad(mx.grad(mx.sin))(x)
array(-0, dtype=float32)
```

----------------------------------------

TITLE: Setting Hyperparameters and Loading MNIST Data (Python)
DESCRIPTION: Sets hyperparameters for the MLP model and training process, including network size, batch size, epochs, and learning rate. It then imports a custom `mnist` data loader and loads the training and testing datasets as MLX arrays.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/examples/mlp.rst#_snippet_4

LANGUAGE: python
CODE:
```
num_layers = 2
hidden_dim = 32
num_classes = 10
batch_size = 256
num_epochs = 10
learning_rate = 1e-1

# Load the data
import mnist
train_images, train_labels, test_images, test_labels = map(
    mx.array, mnist.mnist()
)
```

----------------------------------------

TITLE: Compiling Nested Functions in MLX Python
DESCRIPTION: Illustrates compiling an outer function that calls an inner function, where the inner function is also compiled. Compiling the outermost function is recommended for potential optimization opportunities. Requires the `mlx.core` library.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/usage/compile.rst#_snippet_15

LANGUAGE: python
CODE:
```
@mx.compile
def inner(x):
    return mx.exp(-mx.abs(x))

def outer(x):
    inner(inner(x))

# Compiling the outer function is good to do as it will likely
# be faster even though the inner functions are compiled
fun = mx.compile(outer)
```

----------------------------------------

TITLE: Conditional Python Bindings Build for MLX
DESCRIPTION: This conditional block enables building Python bindings for MLX if MLX_BUILD_PYTHON_BINDINGS is true. It finds Python 3.8, locates the nanobind CMake directory, finds the nanobind package, and then adds the Python source subdirectory for compilation.
SOURCE: https://github.com/ml-explore/mlx/blob/main/CMakeLists.txt#_snippet_16

LANGUAGE: CMake
CODE:
```
if(MLX_BUILD_PYTHON_BINDINGS)
  message(STATUS "Building Python bindings.")
  find_package(
    Python 3.8
    COMPONENTS Interpreter Development.Module
    REQUIRED)
  execute_process(
    COMMAND "${Python_EXECUTABLE}" -m nanobind --cmake_dir
    OUTPUT_STRIP_TRAILING_WHITESPACE
    OUTPUT_VARIABLE nanobind_ROOT)
  find_package(nanobind CONFIG REQUIRED)
  add_subdirectory(${CMAKE_CURRENT_LIST_DIR}/python/src)
endif()
```

----------------------------------------

TITLE: Printing an MLX Module
DESCRIPTION: Demonstrates how to print an mlx.nn.Module instance in Python to inspect its architecture. The output shows the nested layers and their configurations.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/python/nn.rst#_snippet_1

LANGUAGE: python
CODE:
```
print(mlp)
```

----------------------------------------

TITLE: C++ Primitive class definition for Axpby
DESCRIPTION: This C++ code defines the `Axpby` class inheriting from `Primitive`. It outlines the required methods for a primitive, including `eval_cpu`, `eval_gpu`, `jvp`, `vjp`, and `vmap`, which handle evaluation, automatic differentiation, and vectorization.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/dev/extensions.rst#_snippet_3

LANGUAGE: C++
CODE:
```
class Axpby : public Primitive {
  public:
    explicit Axpby(Stream stream, float alpha, float beta)
        : Primitive(stream), alpha_(alpha), beta_(beta){};

    /**
    * A primitive must know how to evaluate itself on the CPU/GPU
    * for the given inputs and populate the output array.
    *
    * To avoid unnecessary allocations, the evaluation function
    * is responsible for allocating space for the array.
    */
    void eval_cpu(
        const std::vector<array>& inputs,
        std::vector<array>& outputs) override;
    void eval_gpu(
        const std::vector<array>& inputs,
        std::vector<array>& outputs) override;

    /** The Jacobian-vector product. */
    std::vector<array> jvp(
        const std::vector<array>& primals,
        const std::vector<array>& tangents,
        const std::vector<int>& argnums) override;

    /** The vector-Jacobian product. */
    std::vector<array> vjp(
        const std::vector<array>& primals,
        const std::vector<array>& cotangents,
        const std::vector<int>& argnums,
        const std::vector<array>& outputs) override;

    /**
    * The primitive must know how to vectorize itself across
    * the given axes. The output is a pair containing the array
    * representing the vectorized computation and the axis which
    * corresponds to the output vectorized dimension.
    */
    virtual std::pair<std::vector<array>, std::vector<int>> vmap(
```

----------------------------------------

TITLE: Define Elementwise Exp Metal Kernel in Python
DESCRIPTION: Defines a Python function `exp_elementwise` that uses `mlx.fast.metal_kernel` to create and execute a custom Metal kernel for elementwise exponential computation. It includes the Metal source code as a string and demonstrates how to instantiate and call the kernel with input arrays and template parameters.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/dev/custom_metal_kernels.rst#_snippet_0

LANGUAGE: python
CODE:
```
def exp_elementwise(a: mx.array):
    source = """
        uint elem = thread_position_in_grid.x;
        T tmp = inp[elem];
        out[elem] = metal::exp(tmp);
    """

    kernel = mx.fast.metal_kernel(
        name="myexp",
        input_names=["inp"],
        output_names=["out"],
        source=source,
    )
    outputs = kernel(
        inputs=[a],
        template=[("T", mx.float32)],
        grid=(a.size, 1, 1),
        threadgroup=(256, 1, 1),
        output_shapes=[a.shape],
        output_dtypes=[a.dtype],
    )
    return outputs[0]

a = mx.random.normal(shape=(4, 16)).astype(mx.float16)
b = exp_elementwise(a)
assert mx.allclose(b, mx.exp(a))
```

----------------------------------------

TITLE: In-Place Updates and Array References in MLX (Shell)
DESCRIPTION: Shows that in-place updates on an MLX array are reflected in all variables referencing the same array object, demonstrated in the shell.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/usage/indexing.rst#_snippet_5

LANGUAGE: shell
CODE:
```
>>> a = mx.array([1, 2, 3])
>>> b = a
>>> b[2] = 0
>>> b
array([1, 2, 0], dtype=int32)
>>> a
array([1, 2, 0], dtype=int32)
```

----------------------------------------

TITLE: Converting MLX Array to NumPy and Back (Copy)
DESCRIPTION: Demonstrates converting an MLX array to a NumPy array and then back to an MLX array. By default, this process involves copying the data.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/usage/numpy.rst#_snippet_0

LANGUAGE: python
CODE:
```
import mlx.core as mx
import numpy as np

a = mx.arange(3)
b = np.array(a) # copy of a
c = mx.array(b) # copy of b
```

----------------------------------------

TITLE: Exporting Multiple MLX Function Traces (Python)
DESCRIPTION: Demonstrates how to export multiple computation graphs (traces) of the same Python function into a single .mlxfn file using mx.exporter. It then shows how to import the function and call it with different argument sets, efficiently handling shared constants.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/usage/export.rst#_snippet_7

LANGUAGE: python
CODE:
```
def fun(x, y=None):
    constant = mx.array(3.0)
    if y is not None:
      x += y
    return x + constant

with mx.exporter("fun.mlxfn", fun) as exporter:
    exporter(mx.array(1.0))
    exporter(mx.array(1.0), y=mx.array(0.0))

imported_function = mx.import_function("fun.mlxfn")

# Call the function with y=None
out, = imported_function(mx.array(1.0))
print(out)

# Call the function with y specified
out, = imported_function(mx.array(1.0), y=mx.array(1.0))
print(out)
```

----------------------------------------

TITLE: Perform Element-wise Axpby on CPU
DESCRIPTION: This C++ snippet implements the core element-wise computation for the Axpby operation on the CPU. It iterates through the output elements, calculates the corresponding offsets in the input arrays `x` and `y` using `mx::elem_to_loc`, and computes `alpha * x[offset] + beta * y[offset]` storing the result in the output array.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/dev/extensions.rst#_snippet_6

LANGUAGE: C++
CODE:
```
      for (size_t out_idx = 0; out_idx < size; out_idx++) {
        // Map linear indices to offsets in x and y
        auto x_offset = mx::elem_to_loc(out_idx, shape, x_strides);
        auto y_offset = mx::elem_to_loc(out_idx, shape, y_strides);

        // We allocate the output to be contiguous and regularly strided
        // (defaults to row major) and hence it doesn't need additional mapping
        out_ptr[out_idx] = alpha * x_ptr[x_offset] + beta * y_ptr[y_offset];
      }
    });
  }
```

----------------------------------------

TITLE: Multi-dimensional Array Indexing with Ellipsis in MLX (Shell)
DESCRIPTION: Shows how to use the ellipsis (...) syntax for indexing multi-dimensional MLX arrays in the shell, similar to NumPy.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/usage/indexing.rst#_snippet_1

LANGUAGE: shell
CODE:
```
>>> arr = mx.arange(8).reshape(2, 2, 2)
>>> arr[:, :, 0]
array(3, dtype=int32)
array([[0, 2],
         [4, 6]], dtype=int32
>>> arr[..., 0]
array([[0, 2],
         [4, 6]], dtype=int32)
```

----------------------------------------

TITLE: Shapeless Compilation Failure with Shape-Dependent Operations in MLX Python
DESCRIPTION: Provides an example where shapeless compilation fails when the function contains operations dependent on the *static* input shape, such as `reshape` using `x.shape`. Changing the input shape after the initial compilation causes an error. Requires the `mlx.core` library.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/usage/compile.rst#_snippet_17

LANGUAGE: python
CODE:
```
def fun(x):
    return x.reshape(x.shape[0] * x.shape[1], -1)

compiled_fun = mx.compile(fun, shapeless=True)

x = mx.random.uniform(shape=(2, 3, 4))

out = compiled_fun(x)

x = mx.random.uniform(shape=(5, 5, 3))

# Error, can't reshape (5, 5, 3) to (6, -1)
out = compiled_fun(x)
```

----------------------------------------

TITLE: Debugging Solution: Disabling MLX Compile - Python
DESCRIPTION: Illustrates how to debug compiled functions by temporarily disabling compilation globally using `mx.disable_compile()`. This allows intermediate arrays to be evaluated (e.g., printed) within the function body for inspection.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/usage/compile.rst#_snippet_6

LANGUAGE: python
CODE:
```
@mx.compile
def fun(x):
    z = -x
    print(z) # Okay
    return mx.exp(z)

mx.disable_compile()
fun(mx.array(5.0))
```

----------------------------------------

TITLE: Gradient Averaging Helper Function Signature (Python)
DESCRIPTION: Introduces the signature for a helper function `all_avg` intended to average gradients across distributed processes. This function will likely use `mx.distributed.all_sum` and divide by the group size to perform the averaging.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/usage/distributed.rst#_snippet_6

LANGUAGE: python
CODE:
```
def all_avg(x):
```

----------------------------------------

TITLE: Exporting MLX Functions with Shapeless Inputs - Python
DESCRIPTION: Demonstrates exporting a function (`mx.abs`) that can accept inputs with dynamic shapes by setting the `shapeless=True` flag in `mx.export_function`. The imported function `imported_abs` is then shown to successfully process both scalar and 1D array inputs.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/usage/export.rst#_snippet_6

LANGUAGE: python
CODE:
```
mx.export_function("fun.mlxfn", mx.abs, mx.array(0.0), shapeless=True)
imported_abs = mx.import_function("fun.mlxfn")

# Ok
out, = imported_abs(mx.array(-1.0))

# Also ok
out, = imported_abs(mx.array([-1.0, -2.0]))
```

----------------------------------------

TITLE: Installing MLX Public Headers
DESCRIPTION: This snippet installs the public header files from the mlx directory to the standard include directory. It includes all .h files but explicitly excludes backend/metal/kernels.h, ensuring only necessary headers are installed.
SOURCE: https://github.com/ml-explore/mlx/blob/main/CMakeLists.txt#_snippet_19

LANGUAGE: CMake
CODE:
```
install(
  DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/mlx
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
  COMPONENT headers
  FILES_MATCHING
  PATTERN "*.h"
  PATTERN "backend/metal/kernels.h" EXCLUDE)
```

----------------------------------------

TITLE: Using mlx.distributed_config for Auto Setup (Shell)
DESCRIPTION: This shell command invokes the `mlx.distributed_config` utility to automatically discover and configure a Thunderbolt ring network among the specified hosts. The `--verbose` flag provides detailed output during the process.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/usage/distributed.rst#_snippet_12

LANGUAGE: shell
CODE:
```
mlx.distributed_config --verbose --hosts host1,host2,host3,host4
```

----------------------------------------

TITLE: Implementing grid_sample Reference MLX Python
DESCRIPTION: Provides a reference implementation of the grid_sample function in MLX using standard tensor operations. It calculates the interpolation weights and indices for bilinear sampling and applies masking for boundary conditions.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/dev/custom_metal_kernels.rst#_snippet_4

LANGUAGE: python
CODE:
```
def grid_sample_ref(x, grid):
    N, H_in, W_in, _ = x.shape
    ix = ((grid[..., 0] + 1) * W_in - 1) / 2
    iy = ((grid[..., 1] + 1) * H_in - 1) / 2

    ix_nw = mx.floor(ix).astype(mx.int32)
    iy_nw = mx.floor(iy).astype(mx.int32)

    ix_ne = ix_nw + 1
    iy_ne = iy_nw

    ix_sw = ix_nw
    iy_sw = iy_nw + 1

    ix_se = ix_nw + 1
    iy_se = iy_nw + 1

    nw = (ix_se - ix)    * (iy_se - iy)
    ne = (ix    - ix_sw) * (iy_sw - iy)
    sw = (ix_ne - ix)    * (iy    - iy_ne)
    se = (ix    - ix_nw) * (iy    - iy_nw)

    I_nw = x[mx.arange(N)[:, None, None], iy_nw, ix_nw, :]
    I_ne = x[mx.arange(N)[:, None, None], iy_ne, ix_ne, :]
    I_sw = x[mx.arange(N)[:, None, None], iy_sw, ix_sw, :]
    I_se = x[mx.arange(N)[:, None, None], iy_se, ix_se, :]

    mask_nw = (iy_nw >= 0) & (iy_nw <= H_in - 1) & (ix_nw >= 0) & (ix_nw <= W_in - 1)
    mask_ne = (iy_ne >= 0) & (iy_ne <= H_in - 1) & (ix_ne >= 0) & (ix_ne <= W_in - 1)
    mask_sw = (iy_sw >= 0) & (iy_sw <= H_in - 1) & (ix_sw >= 0) & (ix_sw <= W_in - 1)
    mask_se = (iy_se >= 0) & (iy_se <= H_in - 1) & (ix_se >= 0) & (ix_se <= W_in - 1)

    I_nw *= mask_nw[..., None]
    I_ne *= mask_ne[..., None]
    I_sw *= mask_sw[..., None]
    I_se *= mask_se[..., None]

    output = nw[..., None] * I_nw + ne[..., None] * I_ne + sw[..., None] * I_sw + se[..., None] * I_se

    return output
```

----------------------------------------

TITLE: Converting MLX Array to JAX Array
DESCRIPTION: Demonstrates the conversion of an MLX array to a JAX array and back, leveraging the buffer protocol.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/usage/numpy.rst#_snippet_4

LANGUAGE: python
CODE:
```
import mlx.core as mx
import jax.numpy as jnp

a = mx.arange(3)
b = jnp.array(a)
c = mx.array(b)
```

----------------------------------------

TITLE: Vectorizing Addition with MLX vmap (Python)
DESCRIPTION: Shows how to use `mlx.core.vmap` to automatically vectorize a function (`lambda x, y: x + y`) over specified input dimensions (`in_axes=(0, 1)`). This replaces a manual loop or list comprehension for improved performance.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/usage/function_transforms.rst#_snippet_6

LANGUAGE: python
CODE:
```
vmap_add = mx.vmap(lambda x, y: x + y, in_axes=(0, 1))
```

----------------------------------------

TITLE: Compiling MLX Function Capturing State as Output (Option 2)
DESCRIPTION: Illustrates using the `outputs` parameter of `mlx.compile` (via `functools.partial`) to implicitly capture updates to external state (a list in this case) without needing to explicitly return it from the compiled function.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/usage/compile.rst#_snippet_9

LANGUAGE: python
CODE:
```
from functools import partial

state = []

# Tell compile to capture state as an output
@partial(mx.compile, outputs=state)
def fun(x, y):
    z = x + y
    state.append(z)
    return mx.exp(z), state

fun(mx.array(1.0), mx.array(2.0))
# Prints [array(3, dtype=float32)]
print(state)
```

----------------------------------------

TITLE: Adding New Axis with None Indexing in MLX (Shell)
DESCRIPTION: Illustrates how indexing with None adds a new dimension (axis) to an MLX array, changing its shape, demonstrated in the shell.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/usage/indexing.rst#_snippet_2

LANGUAGE: shell
CODE:
```
>>> arr = mx.arange(8)
>>> arr.shape
[8]
>>> arr[None].shape
[1, 8]
```

----------------------------------------

TITLE: Converting MLX Array to TensorFlow Tensor
DESCRIPTION: Shows how to convert an MLX array to a TensorFlow tensor using `memoryview` and the buffer protocol.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/usage/numpy.rst#_snippet_5

LANGUAGE: python
CODE:
```
import mlx.core as mx
import tensorflow as tf

a = mx.arange(3)
b = tf.constant(memoryview(a))
c = mx.array(b)
```

----------------------------------------

TITLE: Defining the Cross-Entropy Loss Function (Python)
DESCRIPTION: Defines a function `loss_fn` that calculates the mean cross-entropy loss between the model's predictions and the true labels `y`, given the model and input data `X`.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/examples/mlp.rst#_snippet_2

LANGUAGE: python
CODE:
```
def loss_fn(model, X, y):
    return mx.mean(nn.losses.cross_entropy(model(X), y))
```

----------------------------------------

TITLE: Saving multiple MLX arrays with save_safetensors (Python)
DESCRIPTION: Provides an example of saving multiple MLX arrays to a `.safetensors` file using `mx.save_safetensors`. This function requires the arrays to be provided as a dictionary mapping string names to arrays.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/usage/saving_and_loading.rst#_snippet_4

LANGUAGE: shell
CODE:
```
>>> a = mx.array([1.0])
>>> b = mx.array([2.0])
>>> mx.save_safetensors("arrays", {"a": a, "b": b})
```

----------------------------------------

TITLE: Exporting MLX Function for C++ Import (Python)
DESCRIPTION: Provides the Python code necessary to define and export a simple MLX function (fun) to an .mlxfn file, preparing it for subsequent import and execution within a C++ application.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/usage/export.rst#_snippet_9

LANGUAGE: python
CODE:
```
def fun(x, y):
    return mx.exp(x + y)

x = mx.array(1.0)
y = mx.array(1.0)
mx.export_function("fun.mlxfn", fun, x, y)
```

----------------------------------------

TITLE: Compiling MLX Function Returning State (Option 1)
DESCRIPTION: Shows how to handle mutable state within a compiled MLX function by returning the updated state as one of the function's outputs. The state is appended to within the compiled function and then returned and captured by the caller.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/usage/compile.rst#_snippet_8

LANGUAGE: python
CODE:
```
state = []

@mx.compile
def fun(x, y):
   z = x + y
   state.append(z)
   return mx.exp(z), state

_, state = fun(mx.array(1.0), mx.array(2.0))
# Prints [array(3, dtype=float32)]
print(state)
```

----------------------------------------

TITLE: Adding Executable and Linking MLX Library - CMake
DESCRIPTION: This snippet defines an executable named 'example' from the source file 'example.cpp' and then links it privately against the MLX library. This makes the MLX library's functions and classes available to the 'example' executable during compilation and linking.
SOURCE: https://github.com/ml-explore/mlx/blob/main/examples/cmake_project/CMakeLists.txt#_snippet_3

LANGUAGE: CMake
CODE:
```
add_executable(example example.cpp)
target_link_libraries(example PRIVATE mlx)
```

----------------------------------------

TITLE: Install MLX Library (bash)
DESCRIPTION: Installs the MLX library using the pip package manager. Specifies a minimum required version (0.22) to ensure compatibility with the examples.
SOURCE: https://github.com/ml-explore/mlx/blob/main/examples/export/README.md#_snippet_0

LANGUAGE: bash
CODE:
```
pip install mlx>=0.22
```

----------------------------------------

TITLE: Configuring Windows Build and dlfcn-win32 (CMake)
DESCRIPTION: This section configures the build specifically for Windows. If using MSVC, it disables GGUF and forces building OpenBLAS from source due to compatibility issues. It then fetches and integrates `dlfcn-win32`, a library providing `dlfcn.h` APIs on Windows, ensuring proper dynamic library loading functionality for the `mlx` target.
SOURCE: https://github.com/ml-explore/mlx/blob/main/CMakeLists.txt#_snippet_9

LANGUAGE: CMake
CODE:
```
if(WIN32)
  if(MSVC)
    # GGUF does not build with MSVC.
    set(MLX_BUILD_GGUF OFF)
    # There is no prebuilt OpenBLAS distribution for MSVC.
    set(MLX_BUILD_BLAS_FROM_SOURCE ON)
  endif()
  # Windows implementation of dlfcn.h APIs.
  FetchContent_Declare(
    dlfcn-win32
    GIT_REPOSITORY https://github.com/dlfcn-win32/dlfcn-win32.git
    GIT_TAG v1.4.1
    EXCLUDE_FROM_ALL)
  block()
  set(BUILD_SHARED_LIBS OFF)
  FetchContent_MakeAvailable(dlfcn-win32)
  endblock()
  target_include_directories(mlx PRIVATE "${dlfcn-win32_SOURCE_DIR}/src")
  target_link_libraries(mlx PRIVATE dl)
endif()
```

----------------------------------------

TITLE: Configuring CUDA Architectures for MLX (CMake)
DESCRIPTION: This snippet sets the target CUDA architectures for the `mlx` project to '70;80', which are required for CPU/GPU synchronization with managed memory. It also caches this setting and prints it to the status, allowing for potential performance gains with additional architectures.
SOURCE: https://github.com/ml-explore/mlx/blob/main/mlx/backend/cuda/CMakeLists.txt#_snippet_3

LANGUAGE: CMake
CODE:
```
set(MLX_CUDA_ARCHITECTURES
    "70;80"
    CACHE STRING "CUDA architectures")
message(STATUS "CUDA architectures: ${MLX_CUDA_ARCHITECTURES}")
set_target_properties(mlx PROPERTIES CUDA_ARCHITECTURES
                                     "${MLX_CUDA_ARCHITECTURES}")
```

----------------------------------------

TITLE: Installing MLX with pip (Python)
DESCRIPTION: Installs the MLX Python API using the pip package manager from PyPI. This is the standard way to get the latest release.
SOURCE: https://github.com/ml-explore/mlx/blob/main/README.md#_snippet_0

LANGUAGE: Shell
CODE:
```
pip install mlx
```

----------------------------------------

TITLE: Adding Executable and Linking MLX in CMake (cmake)
DESCRIPTION: Defines the C++ executable target named `example` from the source file `example.cpp`. It then links the `example` executable against the MLX library using `target_link_libraries`, making MLX's functions available to the program.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/dev/mlx_in_cpp.rst#_snippet_6

LANGUAGE: cmake
CODE:
```
add_executable(example example.cpp)
target_link_libraries(example PRIVATE mlx)
```

----------------------------------------

TITLE: Implementing Jacobian-Vector Product (JVP) for MLX Primitive in C++
DESCRIPTION: This C++ function implements the forward-mode automatic differentiation (Jacobian-vector product) for the `axpby` primitive. It handles cases where the differentiation is with respect to only one input (x or y) by scaling the corresponding tangent, or with respect to both by recursively calling the `axpby` operation on the tangents.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/dev/extensions.rst#_snippet_12

LANGUAGE: C++
CODE:
```
/** The Jacobian-vector product. */
    std::vector<array> Axpby::jvp(
            const std::vector<array>& primals,
            const std::vector<array>& tangents,
            const std::vector<int>& argnums) {
        // Forward mode diff that pushes along the tangents
        // The jvp transform on the primitive can be built with ops
        // that are scheduled on the same stream as the primitive

        // If argnums = {0}, we only push along x in which case the
        // jvp is just the tangent scaled by alpha
        // Similarly, if argnums = {1}, the jvp is just the tangent
        // scaled by beta
        if (argnums.size() > 1) {
            auto scale = argnums[0] == 0 ? alpha_ : beta_;
            auto scale_arr = array(scale, tangents[0].dtype());
            return {multiply(scale_arr, tangents[0], stream())};
        }
        // If argnums = {0, 1}, we take contributions from both
        // which gives us jvp = tangent_x * alpha + tangent_y * beta
        else {
            return {axpby(tangents[0], tangents[1], alpha_, beta_, stream())};
        }
    }
```

----------------------------------------

TITLE: Installing MLX Python Package (bash)
DESCRIPTION: Installs or updates the MLX Python package using pip. This is the recommended way to get MLX for use in a C++ project via its Python installation.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/dev/mlx_in_cpp.rst#_snippet_0

LANGUAGE: bash
CODE:
```
pip install -U mlx
```

----------------------------------------

TITLE: Converting MLX Array to PyTorch Tensor
DESCRIPTION: Shows how to convert an MLX array to a PyTorch tensor using `memoryview` and the buffer protocol. Conversion back to MLX requires an intermediate NumPy step.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/usage/numpy.rst#_snippet_3

LANGUAGE: python
CODE:
```
import mlx.core as mx
import torch

a = mx.arange(3)
b = torch.tensor(memoryview(a))
c = mx.array(b.numpy())
```

----------------------------------------

TITLE: Loading a single MLX array (Python)
DESCRIPTION: Shows how to load a single MLX array previously saved with `mx.save` using the `mx.load` function. The function determines the format from the file extension and returns the loaded array.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/usage/saving_and_loading.rst#_snippet_1

LANGUAGE: shell
CODE:
```
>>> mx.load("array.npy")
array([1], dtype=float32)
```

----------------------------------------

TITLE: Launching MLX Program with MPI Backend and Arguments (Shell)
DESCRIPTION: Illustrates how to use the MPI backend with `mlx.launch`, specifying the backend (`--backend mpi`), passing arguments directly to `mpirun` (`--mpi-arg`), and using a JSON hostfile (`--hostfile hosts.json`).
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/usage/launching_distributed.rst#_snippet_3

LANGUAGE: shell
CODE:
```
mlx.launch --backend mpi --mpi-arg '--mca btl_tcp_if_include en0' --hostfile hosts.json my_script.py
```

----------------------------------------

TITLE: Exporting/Importing MLX Functions with Keyword Arguments - Python
DESCRIPTION: Demonstrates exporting a function using a mix of positional and keyword arguments for the example inputs. It shows that the imported function must be called using the exact same keyword arguments, either directly or by providing a dictionary for keyword arguments.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/usage/export.rst#_snippet_3

LANGUAGE: python
CODE:
```
def fun(x, y):
  return x + y

# One argument to fun is positional, the other is a kwarg
mx.export_function("add.mlxfn", fun, x, y=y)

imported_fun = mx.import_function("add.mlxfn")

# Ok
out, = imported_fun(x, y=y)

# Also ok
out, = imported_fun((x,), {"y": y})

# Raises since the keyword argument is missing
out, = imported_fun(x, y)

# Raises since the keyword argument has the wrong key
out, = imported_fun(x, z=y)
```

----------------------------------------

TITLE: Defining simple axpby operation in Python
DESCRIPTION: This Python function demonstrates how to implement the axpby operation (alpha * x + beta * y) using existing MLX operations. It serves as a baseline before implementing a custom primitive.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/dev/extensions.rst#_snippet_0

LANGUAGE: python
CODE:
```
import mlx.core as mx

def simple_axpby(x: mx.array, y: mx.array, alpha: float, beta: float) -> mx.array:
    return alpha * x + beta * y
```

----------------------------------------

TITLE: Saving multiple MLX arrays with savez (Python)
DESCRIPTION: Illustrates saving multiple MLX arrays into a single `.npz` file using `mx.savez`. Arrays can be passed positionally or with keyword arguments for naming.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/usage/saving_and_loading.rst#_snippet_2

LANGUAGE: shell
CODE:
```
>>> a = mx.array([1.0])
>>> b = mx.array([2.0])
>>> mx.savez("arrays", a, b=b)
```

----------------------------------------

TITLE: Initializing MLX Module Parameters with Uniform Distribution
DESCRIPTION: Shows how to initialize all parameters within an `mlx.nn.Module` (a sequential model in this case) using a uniform distribution with specified bounds by applying an initializer function.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/python/nn/init.rst#_snippet_1

LANGUAGE: python
CODE:
```
import mlx.nn as nn
model = nn.Sequential(nn.Linear(5, 10), nn.ReLU(), nn.Linear(10, 5))
init_fn = nn.init.uniform(low=-0.1, high=0.1)
model.apply(init_fn)
```

----------------------------------------

TITLE: Launching Distributed Program on Remote Hosts (Shell)
DESCRIPTION: Shows how to use `mlx.launch` to run a Python script (`my_script.py`) on specified remote hosts (`--hosts ip1,ip2,ip3,ip4`). The output displays the results from processes running on different machines.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/usage/distributed.rst#_snippet_3

LANGUAGE: shell
CODE:
```
$ mlx.launch --hosts ip1,ip2,ip3,ip4 my_script.py
3 array([4, 4, 4, ..., 4, 4, 4], dtype=float32)
2 array([4, 4, 4, ..., 4, 4, 4], dtype=float32)
1 array([4, 4, 4, ..., 4, 4, 4], dtype=float32)
0 array([4, 4, 4, ..., 4, 4, 4], dtype=float32)
```

----------------------------------------

TITLE: Exporting/Importing MLX Functions with Positional/Tuple Inputs - Python
DESCRIPTION: Illustrates that example inputs for `mx.export_function` and actual inputs for the imported function can be provided either as separate positional arguments or grouped within a single tuple. Both methods are valid for defining the function signature and invoking the imported function.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/usage/export.rst#_snippet_2

LANGUAGE: python
CODE:
```
def fun(x, y):
  return x + y

x = mx.array(1.0)
y = mx.array(1.0)

# Both arguments to fun are positional
mx.export_function("add.mlxfn", fun, x, y)

# Same as above
mx.export_function("add.mlxfn", fun, (x, y))

imported_fun = mx.import_function("add.mlxfn")

# Ok
out, = imported_fun(x, y)

# Also ok
out, = imported_fun((x, y))
```

----------------------------------------

TITLE: Finding MLX Package in CMake (cmake)
DESCRIPTION: Instructs CMake to find the MLX package configuration files. This step uses the `MLX_ROOT` variable (set either automatically via Python or manually) to locate the necessary CMake files for MLX. Requires the MLX package to be installed and findable.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/dev/mlx_in_cpp.rst#_snippet_5

LANGUAGE: cmake
CODE:
```
find_package(MLX CONFIG REQUIRED)
```

----------------------------------------

TITLE: Adding Custom Command for Preamble Generation in CMake
DESCRIPTION: This `add_custom_command` defines a rule to generate `compiled_preamble.cpp`. It executes a shell script (`make_compiled_preamble`) using the previously defined `SHELL_CMD` and `SHELL_EXT`, passing various CMake variables as arguments. This command depends on the script itself, a header file, and the `COMPILE_DEPS` list, ensuring the preamble is regenerated when necessary.
SOURCE: https://github.com/ml-explore/mlx/blob/main/mlx/backend/cpu/CMakeLists.txt#_snippet_3

LANGUAGE: CMake
CODE:
```
add_custom_command(
  OUTPUT compiled_preamble.cpp
  COMMAND
    ${SHELL_CMD} ${CMAKE_CURRENT_SOURCE_DIR}/make_compiled_preamble.${SHELL_EXT}
    ${CMAKE_CURRENT_BINARY_DIR}/compiled_preamble.cpp ${COMPILER}
    ${PROJECT_SOURCE_DIR} ${CLANG} ${CMAKE_SYSTEM_PROCESSOR}
  DEPENDS make_compiled_preamble.${SHELL_EXT} compiled_preamble.h
          ${COMPILE_DEPS})
```

----------------------------------------

TITLE: Adding Core MLX C++ Source Files to Target
DESCRIPTION: This CMake command adds a comprehensive list of C++ source files to the `mlx` target as private sources. These files constitute the core implementation of the MLX library, covering various functionalities such as memory allocation, binary/unary operations, convolution, FFT, indexing, matrix multiplication, and more. This ensures all fundamental components of the MLX library are compiled and linked into the main `mlx` target.
SOURCE: https://github.com/ml-explore/mlx/blob/main/mlx/backend/metal/CMakeLists.txt#_snippet_3

LANGUAGE: CMake
CODE:
```
target_sources(
  mlx
  PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/allocator.cpp
          ${CMAKE_CURRENT_SOURCE_DIR}/binary.cpp
          ${CMAKE_CURRENT_SOURCE_DIR}/compiled.cpp
          ${CMAKE_CURRENT_SOURCE_DIR}/conv.cpp
          ${CMAKE_CURRENT_SOURCE_DIR}/copy.cpp
          ${CMAKE_CURRENT_SOURCE_DIR}/custom_kernel.cpp
          ${CMAKE_CURRENT_SOURCE_DIR}/distributed.cpp
          ${CMAKE_CURRENT_SOURCE_DIR}/device.cpp
          ${CMAKE_CURRENT_SOURCE_DIR}/event.cpp
          ${CMAKE_CURRENT_SOURCE_DIR}/eval.cpp
          ${CMAKE_CURRENT_SOURCE_DIR}/fence.cpp
          ${CMAKE_CURRENT_SOURCE_DIR}/fft.cpp
          ${CMAKE_CURRENT_SOURCE_DIR}/hadamard.cpp
          ${CMAKE_CURRENT_SOURCE_DIR}/indexing.cpp
          ${CMAKE_CURRENT_SOURCE_DIR}/logsumexp.cpp
          ${CMAKE_CURRENT_SOURCE_DIR}/matmul.cpp
          ${CMAKE_CURRENT_SOURCE_DIR}/scaled_dot_product_attention.cpp
          ${CMAKE_CURRENT_SOURCE_DIR}/metal.cpp
          ${CMAKE_CURRENT_SOURCE_DIR}/primitives.cpp
          ${CMAKE_CURRENT_SOURCE_DIR}/quantized.cpp
          ${CMAKE_CURRENT_SOURCE_DIR}/normalization.cpp
          ${CMAKE_CURRENT_SOURCE_DIR}/rope.cpp
          ${CMAKE_CURRENT_SOURCE_DIR}/scan.cpp
          ${CMAKE_CURRENT_SOURCE_DIR}/slicing.cpp
          ${CMAKE_CURRENT_SOURCE_DIR}/softmax.cpp
          ${CMAKE_CURRENT_SOURCE_DIR}/sort.cpp
          ${CMAKE_CURRENT_SOURCE_DIR}/reduce.cpp
          ${CMAKE_CURRENT_SOURCE_DIR}/ternary.cpp
          ${CMAKE_CURRENT_SOURCE_DIR}/unary.cpp
          ${CMAKE_CURRENT_SOURCE_DIR}/resident.cpp
          ${CMAKE_CURRENT_SOURCE_DIR}/utils.cpp)
```

----------------------------------------

TITLE: Indexing MLX Array with Another Array (Shell)
DESCRIPTION: Shows how to use an MLX array containing indices to select elements from another MLX array in the shell.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/usage/indexing.rst#_snippet_3

LANGUAGE: shell
CODE:
```
>>> arr = mx.arange(10)
>>> idx = mx.array([5, 7])
>>> arr[idx]
array([5, 7], dtype=int32)
```

----------------------------------------

TITLE: Implementing Grid Sample Gradient with MLX Metal Kernel (Python)
DESCRIPTION: This Python function `grid_sample_grad` computes the gradients for the inputs `x` and `grid` of a grid sample operation using a custom Metal kernel defined via `mlx.fast.metal_kernel`. It takes the input tensor `x`, the grid tensor `grid`, and the cotangent (upstream gradient) `cotangent` as input. The function compiles and executes a Metal kernel named 'grid_sample_grad' with specified inputs, outputs, template types, output shapes, data types, grid size, and threadgroup size. It includes padding for output channels to align with SIMD group size for efficient atomic operations. The function returns the computed gradients `x_grad` and `grid_grad`.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/dev/custom_metal_kernels.rst#_snippet_9

LANGUAGE: Python
CODE:
```
        """
        kernel = mx.fast.metal_kernel(
            name="grid_sample_grad",
            input_names=["x", "grid", "cotangent"],
            output_names=["x_grad", "grid_grad"],
            source=source,
            atomic_outputs=True,
        )
        # pad the output channels to simd group size
        # so that our `simd_sum`s don't overlap.
        simdgroup_size = 32
        C_padded = (C + simdgroup_size - 1) // simdgroup_size * simdgroup_size
        grid_size = B * gN * gM * C_padded
        outputs = kernel(
            inputs=[x, grid, cotangent],
            template=[("T", x.dtype)],
            output_shapes=[x.shape, grid.shape],
            output_dtypes=[x.dtype, x.dtype],
            grid=(grid_size, 1, 1),
            threadgroup=(256, 1, 1),
            init_value=0,
        )
        return outputs[0], outputs[1]

```

----------------------------------------

TITLE: Define MLX C++ Operation Using Axpby Primitive
DESCRIPTION: Defines the `axpby` function which wraps the `Axpby` primitive. It handles input type promotion, casting, broadcasting, and constructs the output array using the primitive and processed inputs. Requires MLX C++ library.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/dev/extensions.rst#_snippet_4

LANGUAGE: C++
CODE:
```
array axpby(
    const array& x, // Input array x
    const array& y, // Input array y
    const float alpha, // Scaling factor for x
    const float beta, // Scaling factor for y
    StreamOrDevice s /* = {} */ // Stream on which to schedule the operation
) {
    // Promote dtypes between x and y as needed
    auto promoted_dtype = promote_types(x.dtype(), y.dtype());

    // Upcast to float32 for non-floating point inputs x and y
    auto out_dtype = issubdtype(promoted_dtype, float32)
        ? promoted_dtype
        : promote_types(promoted_dtype, float32);

    // Cast x and y up to the determined dtype (on the same stream s)
    auto x_casted = astype(x, out_dtype, s);
    auto y_casted = astype(y, out_dtype, s);

    // Broadcast the shapes of x and y (on the same stream s)
    auto broadcasted_inputs = broadcast_arrays({x_casted, y_casted}, s);
    auto out_shape = broadcasted_inputs[0].shape();

    // Construct the array as the output of the Axpby primitive
    // with the broadcasted and upcasted arrays as inputs
    return array(
        /* const std::vector<int>& shape = */ out_shape,
        /* Dtype dtype = */ out_dtype,
        /* std::unique_ptr<Primitive> primitive = */
        std::make_shared<Axpby>(to_stream(s), alpha, beta),
        /* const std::vector<array>& inputs = */ broadcasted_inputs);
}
```

----------------------------------------

TITLE: Importing and Running an Exported MLX Function - Python
DESCRIPTION: Imports the function saved in 'add.mlxfn' using `mx.import_function`. It demonstrates calling the imported function with compatible float32 scalar inputs and shows examples of calls that would fail due to incompatible shapes or data types, highlighting the signature enforcement.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/usage/export.rst#_snippet_1

LANGUAGE: python
CODE:
```
add_fun = mx.import_function("add.mlxfn")

out, = add_fun(mx.array(1.0), mx.array(2.0))
# Prints: array(3, dtype=float32)
print(out)

out, = add_fun(mx.array(1.0), mx.array(3.0))
# Prints: array(4, dtype=float32)
print(out)

# Raises an exception
add_fun(mx.array(1), mx.array(3.0))

# Raises an exception
add_fun(mx.array([1.0, 2.0]), mx.array(3.0))
```

----------------------------------------

TITLE: Launching Distributed Program Locally (Shell)
DESCRIPTION: Demonstrates how to launch a Python script (`my_script.py`) using the `mlx.launch` helper script with 4 local processes (`-n 4`). The output shows the rank and the result from each process.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/usage/distributed.rst#_snippet_2

LANGUAGE: shell
CODE:
```
$ mlx.launch -n 4 my_script.py
3 array([4, 4, 4, ..., 4, 4, 4], dtype=float32)
2 array([4, 4, 4, ..., 4, 4, 4], dtype=float32)
1 array([4, 4, 4, ..., 4, 4, 4], dtype=float32)
0 array([4, 4, 4, ..., 4, 4, 4], dtype=float32)
```

----------------------------------------

TITLE: Implementing the GELU Activation Function - Python
DESCRIPTION: Provides a standard implementation of the Gaussian Error Linear Unit (GELU) activation function using MLX operations like `exp`, `abs`, `erf`, `sqrt`, and basic arithmetic. This function is used later to demonstrate compilation speedup.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/usage/compile.rst#_snippet_2

LANGUAGE: python
CODE:
```
def gelu(x):
    return x * (1 + mx.erf(x / math.sqrt(2))) / 2
```

----------------------------------------

TITLE: Loading multiple MLX arrays with load (Python)
DESCRIPTION: Shows how to load multiple MLX arrays saved in a `.npz` file using `mx.load`. The function returns a dictionary mapping the saved names to the loaded arrays.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/usage/saving_and_loading.rst#_snippet_3

LANGUAGE: shell
CODE:
```
>>> mx.load("arrays.npz")
{'b': array([2], dtype=float32), 'arr_0': array([1], dtype=float32)}
```

----------------------------------------

TITLE: Launching MLX Program on Localhost (Shell)
DESCRIPTION: Shows how to launch a distributed MLX program (`my_script.py`) for testing on the local machine by specifying the number of processes (`-n 2`).
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/usage/launching_distributed.rst#_snippet_1

LANGUAGE: shell
CODE:
```
mlx.launch -n 2 my_script.py
```

----------------------------------------

TITLE: In-Place Updates in MLX Functions with Gradient (Python)
DESCRIPTION: Provides a Python example demonstrating how in-place updates within a function are handled correctly by MLX's automatic differentiation (mx.grad).
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/usage/indexing.rst#_snippet_6

LANGUAGE: python
CODE:
```
def fun(x, idx):
    x[idx] = 2.0
    return x.sum()

dfdx = mx.grad(fun)(mx.array([1.0, 2.0, 3.0]), mx.array([1]))
print(dfdx)  # Prints: array([1, 0, 1], dtype=float32)
```

----------------------------------------

TITLE: Configure and build C++ API (Shell)
DESCRIPTION: Creates a build directory, navigates into it, configures the build using CMake, and compiles the project using make with parallel jobs.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/install.rst#_snippet_10

LANGUAGE: shell
CODE:
```
mkdir -p build && cd build
cmake .. && make -j
```

----------------------------------------

TITLE: Evaluating Model Performance (Python)
DESCRIPTION: Computes the final loss using the optimized parameters `w` and calculates the L2 norm of the difference between the learned parameters and the ground truth parameters `w_star` to evaluate the model's accuracy.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/examples/linear_regression.rst#_snippet_4

LANGUAGE: Python
CODE:
```
loss = loss_fn(w)
error_norm = mx.sum(mx.square(w - w_star)).item() ** 0.5

print(
    f"Loss {loss.item():.5f}, |w-w*| = {error_norm:.5f}, "
)
# Should print something close to: Loss 0.00005, |w-w*| = 0.00364
```

----------------------------------------

TITLE: Installing Metal Library (CMake)
DESCRIPTION: This command handles the installation of the compiled `mlx.metallib` file. It uses `GNUInstallDirs` to determine the standard library installation directory (`CMAKE_INSTALL_LIBDIR`) and specifies that the library is part of the `metallib` component for modular installation. It depends on the `GNUInstallDirs` module.
SOURCE: https://github.com/ml-explore/mlx/blob/main/mlx/backend/metal/kernels/CMakeLists.txt#_snippet_11

LANGUAGE: CMake
CODE:
```
install(
  FILES ${MLX_METAL_PATH}/mlx.metallib
  DESTINATION ${CMAKE_INSTALL_LIBDIR}
  COMPONENT metallib)
```

----------------------------------------

TITLE: C++ implementation of axpby using existing operations
DESCRIPTION: This C++ function provides a simple implementation of the `axpby` operation by leveraging existing MLX `multiply` and `add` operations. It demonstrates how higher-level operations can be built from simpler ones.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/dev/extensions.rst#_snippet_2

LANGUAGE: C++
CODE:
```
array axpby(
    const array& x, // Input array x
    const array& y, // Input array y
    const float alpha, // Scaling factor for x
    const float beta, // Scaling factor for y
    StreamOrDevice s /* = {} */ // Stream on which to schedule the operation */
) {
    // Scale x and y on the provided stream
    auto ax = multiply(array(alpha), x, s);
    auto by = multiply(array(beta), y, s);

    // Add and return
    return add(ax, by, s);
}
```

----------------------------------------

TITLE: Adding MLX Core Nanobind Module (CMake)
DESCRIPTION: This command defines and configures the `core` nanobind module for MLX, specifying its properties like static linking, stable ABI, link-time optimization (LTO), and the source files that comprise the module. It lists all C++ source files required for the Python bindings.
SOURCE: https://github.com/ml-explore/mlx/blob/main/python/src/CMakeLists.txt#_snippet_0

LANGUAGE: CMake
CODE:
```
nanobind_add_module(
  core
  NB_STATIC
  STABLE_ABI
  LTO
  NOMINSIZE
  NB_DOMAIN
  mlx
  ${CMAKE_CURRENT_SOURCE_DIR}/mlx.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/array.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/convert.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/device.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/distributed.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/export.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/fast.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/fft.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/indexing.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/load.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/metal.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/memory.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/mlx_func.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/ops.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/stream.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/transforms.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/random.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/linalg.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/constants.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/trees.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/utils.cpp)
```

----------------------------------------

TITLE: Implementing grid_sample Custom Kernel MLX Python
DESCRIPTION: Implements the grid_sample function using MLX's custom function decorator and a Metal kernel for accelerated execution on the GPU. It includes input validation and the Metal source code for the forward pass calculation.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/dev/custom_metal_kernels.rst#_snippet_5

LANGUAGE: python
CODE:
```
@mx.custom_function
def grid_sample(x, grid):

    assert x.ndim == 4, "`x` must be 4D."
    assert grid.ndim == 4, "`grid` must be 4D."

    B, _, _, C = x.shape
    _, gN, gM, D = grid.shape
    out_shape = (B, gN, gM, C)

    assert D == 2, "Last dim of `grid` must be size 2."

    source = """
        uint elem = thread_position_in_grid.x;
        int H = x_shape[1];
        int W = x_shape[2];
        int C = x_shape[3];
        int gH = grid_shape[1];
        int gW = grid_shape[2];

        int w_stride = C;
        int h_stride = W * w_stride;
        int b_stride = H * h_stride;

        uint grid_idx = elem / C * 2;
        float ix = ((grid[grid_idx] + 1) * W - 1) / 2;
        float iy = ((grid[grid_idx + 1] + 1) * H - 1) / 2;

        int ix_nw = floor(ix);
        int iy_nw = floor(iy);

        int ix_ne = ix_nw + 1;
        int iy_ne = iy_nw;

        int ix_sw = ix_nw;
        int iy_sw = iy_nw + 1;

        int ix_se = ix_nw + 1;
        int iy_se = iy_nw + 1;

        T nw = (ix_se - ix)    * (iy_se - iy);
        T ne = (ix    - ix_sw) * (iy_sw - iy);
        T sw = (ix_ne - ix)    * (iy    - iy_ne);
        T se = (ix    - ix_nw) * (iy    - iy_nw);

        int batch_idx = elem / C / gH / gW * b_stride;
        int channel_idx = elem % C;
        int base_idx = batch_idx + channel_idx;

        T I_nw = x[base_idx + iy_nw * h_stride + ix_nw * w_stride];
        T I_ne = x[base_idx + iy_ne * h_stride + ix_ne * w_stride];
        T I_sw = x[base_idx + iy_sw * h_stride + ix_sw * w_stride];
        T I_se = x[base_idx + iy_se * h_stride + ix_se * w_stride];

        I_nw = iy_nw >= 0 && iy_nw <= H - 1 && ix_nw >= 0 && ix_nw <= W - 1 ? I_nw : 0;
        I_ne = iy_ne >= 0 && iy_ne <= H - 1 && ix_ne >= 0 && ix_ne <= W - 1 ? I_ne : 0;
        I_sw = iy_sw >= 0 && iy_sw <= H - 1 && ix_sw >= 0 && ix_sw <= W - 1 ? I_sw : 0;
        I_se = iy_se >= 0 && iy_se <= H - 1 && ix_se >= 0 && ix_se <= W - 1 ? I_se : 0;

        out[elem] = nw * I_nw + ne * I_ne + sw * I_sw + se * I_se;
    """
    kernel = mx.fast.metal_kernel(
        name="grid_sample",
        input_names=["x", "grid"],
        output_names=["out"],
        source=source,
    )
    outputs = kernel(
        inputs=[x, grid],
        template=[("T", x.dtype)],
        output_shapes=[out_shape],
        output_dtypes=[x.dtype],
        grid=(np.prod(out_shape), 1, 1),
        threadgroup=(256, 1, 1),
    )
    return outputs[0]
```

----------------------------------------

TITLE: Implementing Vector-Jacobian Product (VJP) for MLX Primitive in C++
DESCRIPTION: This C++ function implements the reverse-mode automatic differentiation (vector-Jacobian product) for the `axpby` primitive. It computes the VJP for each argument specified in `argnums` by scaling the cotangent with the corresponding alpha or beta factor.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/dev/extensions.rst#_snippet_13

LANGUAGE: C++
CODE:
```
/** The vector-Jacobian product. */
    std::vector<array> Axpby::vjp(
            const std::vector<array>& primals,
            const std::vector<array>& cotangents,
            const std::vector<int>& argnums,
            const std::vector<int>& /* unused */) {
        // Reverse mode diff
        std::vector<array> vjps;
        for (auto arg : argnums) {
            auto scale = arg == 0 ? alpha_ : beta_;
            auto scale_arr = array(scale, cotangents[0].dtype());
            vjps.push_back(multiply(scale_arr, cotangents[0], stream()));
        }
        return vjps;
    }
```

----------------------------------------

TITLE: Install MLX Requirements - Shell
DESCRIPTION: Installs the project dependencies listed in the requirements.txt file. This is a prerequisite for building and running the project.
SOURCE: https://github.com/ml-explore/mlx/blob/main/examples/extensions/README.md#_snippet_1

LANGUAGE: Shell
CODE:
```
pip install -r requirements.txt
```

----------------------------------------

TITLE: Generating Random Numbers (Explicit Key) - MLX Python
DESCRIPTION: This snippet shows how to use an explicit PRNG key in MLX for reproducible random number generation. It creates a key from a seed (0) and then uses this key in each call to `mx.random.uniform`, resulting in the same pseudo-random number being printed three times.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/python/random.rst#_snippet_1

LANGUAGE: python
CODE:
```
key = mx.random.key(0)
for _ in range(3):
  print(mx.random.uniform(key=key))
```

----------------------------------------

TITLE: Exporting an MLX Module Without Parameters - Python
DESCRIPTION: Explains how to export an MLX module's functionality without embedding its parameters in the file. A wrapper function `call` is created that accepts parameters as keyword arguments and updates the module. The parameters are passed as separate example inputs during the `mx.export_function` call.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/usage/export.rst#_snippet_5

LANGUAGE: python
CODE:
```
model = nn.Linear(4, 4)
mx.eval(model.parameters())

def call(x, **params):
  # Set the model's parameters to the input parameters
  model.update(tree_unflatten(list(params.items())))
  return model(x)

params = dict(tree_flatten(model.parameters()))
mx.export_function("model.mlxfn", call, (mx.zeros(4),), params)
```

----------------------------------------

TITLE: Generating Random Numbers (Implicit Key) - MLX Python
DESCRIPTION: This snippet demonstrates generating a sequence of unique pseudo-random numbers using the default implicit global PRNG state in MLX. It iterates three times, printing a new random uniform number in each iteration.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/python/random.rst#_snippet_0

LANGUAGE: python
CODE:
```
for _ in range(3):
  print(mx.random.uniform())
```

----------------------------------------

TITLE: Conditionally Adding SafeTensors Support (CMake)
DESCRIPTION: This snippet conditionally includes either 'safetensors.cpp' or 'no_safetensors.cpp' based on the 'MLX_BUILD_SAFETENSORS' CMake flag. This allows the MLX library to be built with or without SafeTensors support, optimizing the build for specific feature requirements.
SOURCE: https://github.com/ml-explore/mlx/blob/main/mlx/io/CMakeLists.txt#_snippet_1

LANGUAGE: CMake
CODE:
```
if(MLX_BUILD_SAFETENSORS)
  target_sources(mlx PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/safetensors.cpp)
else()
  target_sources(mlx PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/no_safetensors.cpp)
endif()
```

----------------------------------------

TITLE: Compiling Core Metal Kernels (CMake)
DESCRIPTION: This block invokes the `build_kernel` function for a set of core Metal kernels, such as `arg_reduce`, `conv`, `gemv`, `layer_norm`, `random`, `rms_norm`, `rope`, and `scaled_dot_product_attention`. It also conditionally compiles `fence` if `MLX_METAL_VERSION` is sufficient. Some calls include specific header dependencies. This depends on the `build_kernel` function.
SOURCE: https://github.com/ml-explore/mlx/blob/main/mlx/backend/metal/kernels/CMakeLists.txt#_snippet_3

LANGUAGE: CMake
CODE:
```
build_kernel(arg_reduce)
build_kernel(conv steel/conv/params.h)
build_kernel(gemv steel/utils.h)
build_kernel(layer_norm)
build_kernel(random)
build_kernel(rms_norm)
build_kernel(rope)
build_kernel(scaled_dot_product_attention sdpa_vector.h)
if(MLX_METAL_VERSION GREATER_EQUAL 320)
  build_kernel(fence)
endif()
```

----------------------------------------

TITLE: Configuring Python Package Build with setuptools (Python)
DESCRIPTION: This Python snippet defines the setup.py file for the 'mlx_sample_extensions' package, using MLX's CMakeExtension and CMakeBuild classes to integrate the CMake build process into setuptools.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/dev/extensions.rst#_snippet_19

LANGUAGE: python
CODE:
```
from mlx import extension
from setuptools import setup

if __name__ == "__main__":
    setup(
        name="mlx_sample_extensions",
        version="0.0.0",
        description="Sample C++ and Metal extensions for MLX primitives.",
        ext_modules=[extension.CMakeExtension("mlx_sample_extensions._ext")],
        cmdclass={"build_ext": extension.CMakeBuild},
        packages=["mlx_sample_extensions"],
        package_data={"mlx_sample_extensions": ["*.so", "*.dylib", "*.metallib"]},
        extras_require={"dev":[]},
        zip_safe=False,
        python_requires=">=3.8",
    )
```

----------------------------------------

TITLE: Instantiate Metal Axpby Kernel for Data Types
DESCRIPTION: These C++ lines use the `instantiate_kernel` mechanism to create specific instances of the templated Metal kernel `axpby_general` for various floating-point data types: `float32`, `float16`, `bfloat16`, and `complex64`. Each instantiation is registered with a unique string name used by the host code to select the correct kernel for execution on the GPU.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/dev/extensions.rst#_snippet_9

LANGUAGE: C++
CODE:
```
    instantiate_kernel("axpby_general_float32", axpby_general, float)
    instantiate_kernel("axpby_general_float16", axpby_general, float16_t)
    instantiate_kernel("axpby_general_bfloat16", axpby_general, bfloat16_t)
    instantiate_kernel("axpby_general_complex64", axpby_general, complex64_t)
```

----------------------------------------

TITLE: Creating Arrays in Unified Memory (MLX Python)
DESCRIPTION: Demonstrates how arrays are created in MLX, residing automatically in unified memory without specifying a device location.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/usage/unified_memory.rst#_snippet_0

LANGUAGE: python
CODE:
```
a = mx.random.normal((100,))
b = mx.random.normal((100,))
```

----------------------------------------

TITLE: Defining CMake Function for MLX Example Builds
DESCRIPTION: This CMake function `build_example` creates an executable from a given source file and links it privately against the `mlx` library. It extracts the base name of the source file to use as the target executable name, simplifying the build process for multiple examples.
SOURCE: https://github.com/ml-explore/mlx/blob/main/examples/cpp/CMakeLists.txt#_snippet_0

LANGUAGE: CMake
CODE:
```
function(build_example SRCFILE)
  get_filename_component(src_name ${SRCFILE} NAME_WE)
  set(target "${src_name}")
  add_executable(${target} ${SRCFILE})
  target_link_libraries(${target} PRIVATE mlx)
endfunction(build_example)
```

----------------------------------------

TITLE: Integrating fmtlib/fmt Dependency in MLX CMake
DESCRIPTION: This CMake snippet declares and makes available the fmtlib/fmt library, a formatting library, as a build dependency. It fetches a specific Git tag and links it privately to the mlx target as a header-only library for build interfaces.
SOURCE: https://github.com/ml-explore/mlx/blob/main/CMakeLists.txt#_snippet_15

LANGUAGE: CMake
CODE:
```
FetchContent_Declare(
  fmt
  GIT_REPOSITORY https://github.com/fmtlib/fmt.git
  GIT_TAG 10.2.1
  EXCLUDE_FROM_ALL)
FetchContent_MakeAvailable(fmt)
target_link_libraries(mlx PRIVATE $<BUILD_INTERFACE:fmt::fmt-header-only>)
```

----------------------------------------

TITLE: Building Python Bindings Module with CMake (CMake)
DESCRIPTION: This CMake snippet uses 'nanobind_add_module' to build the Python extension module '_ext' from the bindings source file and links it to the previously built C++ extension library 'mlx_ext'.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/dev/extensions.rst#_snippet_18

LANGUAGE: cmake
CODE:
```
nanobind_add_module(
  _ext
  NB_STATIC STABLE_ABI LTO NOMINSIZE
  NB_DOMAIN mlx
  ${CMAKE_CURRENT_LIST_DIR}/bindings.cpp
)
target_link_libraries(_ext PRIVATE mlx_ext)

if(BUILD_SHARED_LIBS)
  target_link_options(_ext PRIVATE -Wl,-rpath,@loader_path)
endif()
```

----------------------------------------

TITLE: Implement MLX C++ Axpby Primitive CPU Evaluation
DESCRIPTION: Provides the template implementation `axpby_impl` for the CPU backend of the `Axpby` primitive. It allocates memory for the output, registers inputs and output with the CPU command encoder, and prepares a lambda function for the element-wise computation kernel. Note: The element-wise loop body is not shown in this snippet. Requires MLX C++ library.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/dev/extensions.rst#_snippet_5

LANGUAGE: C++
CODE:
```
template <typename T>
void axpby_impl(
    const mx::array& x,
    const mx::array& y,
    mx::array& out,
    float alpha_,
    float beta_,
    mx::Stream stream) {
  out.set_data(mx::allocator::malloc(out.nbytes()));

  // Get the CPU command encoder and register input and output arrays
  auto& encoder = mx::cpu::get_command_encoder(stream);
  encoder.set_input_array(x);
  encoder.set_input_array(y);
  encoder.set_output_array(out);

  // Launch the CPU kernel
  encoder.dispatch([x_ptr = x.data<T>(),
                    y_ptr = y.data<T>(),
                    out_ptr = out.data<T>(),
                    size = out.size(),
                    shape = out.shape(),
                    x_strides = x.strides(),
                    y_strides = y.strides(),
                    alpha_,
                    beta_]() {

    // Cast alpha and beta to the relevant types
    T alpha = static_cast<T>(alpha_);
    T beta = static_cast<T>(beta_);

    // Do the element-wise operation for each output

```

----------------------------------------

TITLE: Demonstrating MLX Compile Caching - Python
DESCRIPTION: Illustrates the caching behavior of `mx.compile`. Shows that the compilation process only occurs on the first call to a compiled function, and subsequent calls (even via `mx.compile(fun)(...)`) reuse the cached compiled version.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/usage/compile.rst#_snippet_1

LANGUAGE: python
CODE:
```
def fun(x, y):
    return mx.exp(-x) + y

x = mx.array(1.0)
y = mx.array(2.0)

compiled_fun = mx.compile(fun)

# Compiled here
compiled_fun(x, y)

# Not compiled again
compiled_fun(x, y)

# Not compiled again
mx.compile(fun)(x, y)
```

----------------------------------------

TITLE: Applying Uniform Initialization to an Array in MLX
DESCRIPTION: Demonstrates how to create a uniform initializer function using `mlx.nn.init.uniform` and apply it to an MLX array to initialize its values.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/python/nn/init.rst#_snippet_0

LANGUAGE: python
CODE:
```
import mlx.core as mx
import mlx.nn as nn

init_fn = nn.init.uniform()

# Produces a [2, 2] uniform matrix
param = init_fn(mx.zeros((2, 2)))
```

----------------------------------------

TITLE: Compute First Derivative with mx.grad (Shell)
DESCRIPTION: Demonstrates using `mx.grad` to compute the first derivative of `mx.sin` and evaluating it at pi, showing it matches `mx.cos(pi)`.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/usage/function_transforms.rst#_snippet_0

LANGUAGE: shell
CODE:
```
>>> dfdx = mx.grad(mx.sin)
>>> dfdx(mx.array(mx.pi))
array(-1, dtype=float32)
>>> mx.cos(mx.array(mx.pi))
array(-1, dtype=float32)
```

----------------------------------------

TITLE: Integrating nlohmann/json Dependency in MLX CMake
DESCRIPTION: This CMake snippet declares and makes available the nlohmann/json library as a build dependency. It downloads the specified version from GitHub and configures the mlx target to include its headers privately for build interfaces.
SOURCE: https://github.com/ml-explore/mlx/blob/main/CMakeLists.txt#_snippet_12

LANGUAGE: CMake
CODE:
```
message(STATUS "Downloading json")
FetchContent_Declare(
  json
  URL https://github.com/nlohmann/json/releases/download/v3.11.3/json.tar.xz)
FetchContent_MakeAvailable(json)
target_include_directories(
  mlx PRIVATE $<BUILD_INTERFACE:${json_SOURCE_DIR}/single_include/nlohmann>)
```

----------------------------------------

TITLE: Conditional Installation of Metal C++ Headers
DESCRIPTION: This conditional block installs the metal_cpp source directory to the standard include path if MLX_BUILD_METAL is enabled. This ensures that Metal C++ headers are available for projects that depend on MLX's Metal backend.
SOURCE: https://github.com/ml-explore/mlx/blob/main/CMakeLists.txt#_snippet_20

LANGUAGE: CMake
CODE:
```
if(MLX_BUILD_METAL)

  # Install metal cpp
  install(
    DIRECTORY ${metal_cpp_SOURCE_DIR}/
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/metal_cpp
    COMPONENT metal_cpp_source)

endif()
```

----------------------------------------

TITLE: Binding and Dispatching Metal Kernel in MLX C++
DESCRIPTION: This C++ snippet demonstrates how to register a Metal library, retrieve a specific kernel, prepare a compute command encoder, set the kernel's pipeline state, encode input and output arrays, encode scalar and vector parameters, and finally dispatch the kernel threads on the GPU.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/dev/extensions.rst#_snippet_11

LANGUAGE: C++
CODE:
```
d.register_library("mlx_ext");

        // Make a kernel from this metal library
        auto kernel = d.get_kernel(kname.str(), "mlx_ext");

        // Prepare to encode kernel
        auto& compute_encoder = d.get_command_encoder(s.index);
        compute_encoder.set_compute_pipeline_state(kernel);

        // Kernel parameters are registered with buffer indices corresponding to
        // those in the kernel declaration at axpby.metal
        int ndim = out.ndim();
        size_t nelem = out.size();

        // Encode input arrays to kernel
        compute_encoder.set_input_array(x, 0);
        compute_encoder.set_input_array(y, 1);

        // Encode output arrays to kernel
        compute_encoder.set_output_array(out, 2);

        // Encode alpha and beta
        compute_encoder.set_bytes(alpha_, 3);
        compute_encoder.set_bytes(beta_, 4);

        // Encode shape, strides and ndim
        compute_encoder.set_vector_bytes(x.shape(), 5);
        compute_encoder.set_vector_bytes(x.strides(), 6);
        compute_encoder.set_bytes(y.strides(), 7);
        compute_encoder.set_bytes(ndim, 8);

        // We launch 1 thread for each input and make sure that the number of
        // threads in any given threadgroup is not higher than the max allowed
        size_t tgp_size = std::min(nelem, kernel->maxTotalThreadsPerThreadgroup());

        // Fix the 3D size of each threadgroup (in terms of threads)
        MTL::Size group_dims = MTL::Size(tgp_size, 1, 1);

        // Fix the 3D size of the launch grid (in terms of threads)
        MTL::Size grid_dims = MTL::Size(nelem, 1, 1);

        // Launch the grid with the given number of threads divided among
        // the given threadgroups
        compute_encoder.dispatch_threads(grid_dims, group_dims);
    }
```

----------------------------------------

TITLE: Metal Kernel for Element-wise Axpby
DESCRIPTION: This C++ Metal kernel `axpby_general` performs the element-wise Axpby operation on the GPU. It is templated by data type `T` and takes input arrays `x`, `y`, output array `out`, scalar parameters `alpha`, `beta`, shape, strides, and dimensionality as Metal buffers. Each thread computes the output element at its grid position by mapping the linear index to array offsets and applying the `alpha * x + beta * y` formula.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/dev/extensions.rst#_snippet_8

LANGUAGE: C++
CODE:
```
    template <typename T>
    [[kernel]] void axpby_general(
            device const T* x [[buffer(0)]],
            device const T* y [[buffer(1)]],
            device T* out [[buffer(2)]],
            constant const float& alpha [[buffer(3)]],
            constant const float& beta [[buffer(4)]],
            constant const int* shape [[buffer(5)]],
            constant const int64_t* x_strides [[buffer(6)]],
            constant const int64_t* y_strides [[buffer(7)]],
            constant const int& ndim [[buffer(8)]],
            uint index [[thread_position_in_grid]]) {
        // Convert linear indices to offsets in array
        auto x_offset = elem_to_loc(index, shape, x_strides, ndim);
        auto y_offset = elem_to_loc(index, shape, y_strides, ndim);

        // Do the operation and update the output
        out[index] =
            static_cast<T>(alpha) * x[x_offset] + static_cast<T>(beta) * y[y_offset];
    }
```

----------------------------------------

TITLE: Applying Transformations to Imported MLX Functions (Python)
DESCRIPTION: Shows that standard MLX function transformations like mx.grad and mx.compile can be applied directly to functions imported from an .mlxfn file, just like regular Python functions.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/usage/export.rst#_snippet_8

LANGUAGE: python
CODE:
```
def fun(x):
    return mx.sin(x)

x = mx.array(0.0)
mx.export_function("sine.mlxfn", fun, x)

imported_fun = mx.import_function("sine.mlxfn")

# Take the derivative of the imported function
dfdx = mx.grad(lambda x: imported_fun(x)[0])
# Prints: array(1, dtype=float32)
print(dfdx(x))

# Compile the imported function
mx.compile(imported_fun)
# Prints: array(0, dtype=float32)
print(compiled_fun(x)[0])
```

----------------------------------------

TITLE: Fetching Doctest Testing Framework
DESCRIPTION: Declares and makes available the doctest testing framework as a Git submodule, specifying its repository URL and a specific commit hash for version control.
SOURCE: https://github.com/ml-explore/mlx/blob/main/tests/CMakeLists.txt#_snippet_1

LANGUAGE: CMake
CODE:
```
FetchContent_Declare(
  doctest
  GIT_REPOSITORY "https://github.com/onqtam/doctest"
  GIT_TAG "ae7a13539fb71f270b87eb2e874fbac80bc8dda2")
FetchContent_MakeAvailable(doctest)
```

----------------------------------------

TITLE: Implementing Vectorization (VMAP) for MLX Primitive in C++
DESCRIPTION: This C++ function provides a placeholder implementation for the vectorization (vmap) transformation for the `axpby` primitive. It currently throws a runtime error, indicating that the vmap transformation is not yet implemented for this primitive.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/dev/extensions.rst#_snippet_14

LANGUAGE: C++
CODE:
```
/** Vectorize primitive along given axis */
    std::pair<std::vector<array>, std::vector<int>> Axpby::vmap(
            const std::vector<array>& inputs,
            const std::vector<int>& axes) {
        throw std::runtime_error("[Axpby] vmap not implemented.");
    }
```

----------------------------------------

TITLE: Disabling MLX Export Symbol Definition
DESCRIPTION: This snippet prevents the mlx_EXPORTS define symbol from being added to the mlx shared library. This is often done to control symbol visibility and avoid potential conflicts or unnecessary exports.
SOURCE: https://github.com/ml-explore/mlx/blob/main/CMakeLists.txt#_snippet_14

LANGUAGE: CMake
CODE:
```
# Do not add mlx_EXPORTS define for shared library.
set_target_properties(mlx PROPERTIES DEFINE_SYMBOL "")
```

----------------------------------------

TITLE: Launching MLX Distributed Program with mlx.launch (MPI)
DESCRIPTION: This shell command shows the basic usage of the `mlx.launch` helper script to run a distributed MLX program (`test.py`) using the MPI backend. The `-n 2` argument specifies that the program should be launched with 2 processes.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/usage/distributed.rst#_snippet_9

LANGUAGE: shell
CODE:
```
$ mlx.launch --backend mpi -n 2 test.py
```

----------------------------------------

TITLE: Setting MLX Python Bindings Output Directory (CMake)
DESCRIPTION: This block conditionally sets the `MLX_PYTHON_BINDINGS_OUTPUT_DIRECTORY` variable. If it's not already defined, it defaults to `CMAKE_LIBRARY_OUTPUT_DIRECTORY` if available, otherwise to `PROJECT_BINARY_DIR`, ensuring a consistent output location for the Python module.
SOURCE: https://github.com/ml-explore/mlx/blob/main/python/src/CMakeLists.txt#_snippet_1

LANGUAGE: CMake
CODE:
```
if(NOT MLX_PYTHON_BINDINGS_OUTPUT_DIRECTORY)
  if(NOT CMAKE_LIBRARY_OUTPUT_DIRECTORY)
    set(MLX_PYTHON_BINDINGS_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR})
  else()
    set(MLX_PYTHON_BINDINGS_OUTPUT_DIRECTORY ${CMAKE_LIBRARY_OUTPUT_DIRECTORY})
  endif()
endif()
```

----------------------------------------

TITLE: Install MLX in Editable Mode - Shell
DESCRIPTION: Installs the MLX project from the current directory in editable mode, allowing changes to the source code to be reflected without reinstallation. Useful for development.
SOURCE: https://github.com/ml-explore/mlx/blob/main/examples/extensions/README.md#_snippet_0

LANGUAGE: Shell
CODE:
```
pip install -e .
```

----------------------------------------

TITLE: Importing Core MLX Modules for Distributed Operations (Python)
DESCRIPTION: This snippet imports essential MLX core components (`array`, `Dtype`, `Device`, `Stream`), the `Group` class specifically for distributed computing, and standard Python typing utilities. These imports are foundational for developing distributed machine learning applications with MLX.
SOURCE: https://github.com/ml-explore/mlx/blob/main/python/mlx/_stub_patterns.txt#_snippet_0

LANGUAGE: Python
CODE:
```
from mlx.core import array, Dtype, Device, Stream
from mlx.core.distributed import Group
from typing import Sequence, Optional, Union
```

----------------------------------------

TITLE: Defining the Accuracy Evaluation Function (Python)
DESCRIPTION: Defines a function `eval_fn` to compute the accuracy of the model's predictions on a given dataset `X` with true labels `y`. It compares the index of the maximum output (predicted class) with the true label.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/examples/mlp.rst#_snippet_3

LANGUAGE: python
CODE:
```
def eval_fn(model, X, y):
    return mx.mean(mx.argmax(model(X), axis=1) == y)
```

----------------------------------------

TITLE: Setting Up CMake Project and CXX Standards
DESCRIPTION: This snippet defines the minimum CMake version, names the project '_ext' with CXX language support, and configures C++ standards (C++17, required, position-independent code). It also introduces an option to build shared libraries.
SOURCE: https://github.com/ml-explore/mlx/blob/main/examples/extensions/CMakeLists.txt#_snippet_0

LANGUAGE: CMake
CODE:
```
cmake_minimum_required(VERSION 3.27)

project(_ext LANGUAGES CXX)

# ----------------------------- Setup -----------------------------
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

option(BUILD_SHARED_LIBS "Build extensions as a shared library" ON)
```

----------------------------------------

TITLE: Invoking CMake Function for MLX Examples
DESCRIPTION: These lines demonstrate the usage of the `build_example` CMake function to compile various C++ tutorial and example files (e.g., `tutorial.cpp`, `linear_regression.cpp`) into executables. Each call automatically links the specified source file with the MLX library.
SOURCE: https://github.com/ml-explore/mlx/blob/main/examples/cpp/CMakeLists.txt#_snippet_1

LANGUAGE: CMake
CODE:
```
build_example(tutorial.cpp)
build_example(linear_regression.cpp)
build_example(logistic_regression.cpp)
build_example(metal_capture.cpp)
build_example(distributed.cpp)
```

----------------------------------------

TITLE: Installing MLX with conda (Python)
DESCRIPTION: Installs the MLX Python API using the conda package manager from the conda-forge channel. This is an alternative installation method for users preferring conda.
SOURCE: https://github.com/ml-explore/mlx/blob/main/README.md#_snippet_1

LANGUAGE: Shell
CODE:
```
conda install -c conda-forge mlx
```

----------------------------------------

TITLE: Generate Python API stubs (Shell)
DESCRIPTION: Generates Python stub files (`.pyi`) using `setup.py` to enable auto-completion and type checking in IDEs.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/install.rst#_snippet_8

LANGUAGE: shell
CODE:
```
python setup.py generate_stubs
```

----------------------------------------

TITLE: Capturing MLX Metal GPU Trace (Python)
DESCRIPTION: Demonstrates how to programmatically start and stop a Metal GPU trace capture using `mlx.metal.start_capture` and `mlx.metal.stop_capture`. It initializes tensors, performs an initial evaluation, starts the capture, performs operations within the capture, and stops the capture, saving the trace to a file. Requires running with `MTL_CAPTURE_ENABLED=1`.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/dev/metal_debugger.rst#_snippet_0

LANGUAGE: python
CODE:
```
import mlx.core as mx

a = mx.random.uniform(shape=(512, 512))
b = mx.random.uniform(shape=(512, 512))
mx.eval(a, b)

trace_file = "mlx_trace.gputrace"

# Make sure to run with MTL_CAPTURE_ENABLED=1 and
# that the path trace_file does not already exist.
mx.metal.start_capture(trace_file)

for _ in range(10):
  mx.eval(mx.add(a, b))

mx.metal.stop_capture()
```

----------------------------------------

TITLE: Generating MLX Xcode Project with Metal Debugging (Shell)
DESCRIPTION: Provides shell commands to create a build directory, configure the MLX project using CMake with the `MLX_METAL_DEBUG=ON` flag and the Xcode generator, and open the generated Xcode project file. This allows running and debugging MLX code within Xcode.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/dev/metal_debugger.rst#_snippet_1

LANGUAGE: shell
CODE:
```
mkdir build && cd build
cmake .. -DMLX_METAL_DEBUG=ON -G Xcode
open mlx.xcodeproj
```

----------------------------------------

TITLE: Timing MLX Function Execution - Python
DESCRIPTION: Defines a helper function `timeit` to benchmark the execution time of MLX functions. It includes a warm-up phase and uses `mx.eval` to ensure computation is completed before timing, providing a more accurate measurement.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/usage/compile.rst#_snippet_3

LANGUAGE: python
CODE:
```
import time

def timeit(fun, x):
    # warm up
    for _ in range(10):
        mx.eval(fun(x))

    tic = time.perf_counter()
    for _ in range(100):
        mx.eval(fun(x))
    toc = time.perf_counter()
    tpi = 1e3 * (toc - tic) / 100
    print(f"Time per iteration {tpi:.3f} (ms)")
```

----------------------------------------

TITLE: Suppressing NVCC Warnings on MLX Headers (CMake)
DESCRIPTION: This snippet adds a compile option to suppress specific NVCC warnings (diag_suppress=997) when compiling CUDA language files for the `mlx` target. This helps to reduce noise from warnings originating in MLX headers.
SOURCE: https://github.com/ml-explore/mlx/blob/main/mlx/backend/cuda/CMakeLists.txt#_snippet_7

LANGUAGE: CMake
CODE:
```
target_compile_options(mlx PRIVATE $<$<COMPILE_LANGUAGE:CUDA>:-Xcudafe
                                   --diag_suppress=997>)
```

----------------------------------------

TITLE: Counting MLX Module Parameters
DESCRIPTION: Demonstrates how to use mlx.utils.tree_flatten to flatten the parameter tree of an mlx.nn.Module and then sum the sizes of all parameters to get the total number of elements.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/python/nn.rst#_snippet_3

LANGUAGE: python
CODE:
```
from mlx.utils import tree_flatten
num_params = sum(v.size for _, v in tree_flatten(mlp.parameters()))
```

----------------------------------------

TITLE: Locating MLX Library Configuration - CMake
DESCRIPTION: This command finds the MLX library using its configuration file, ensuring that the library is a required dependency for the project. It relies on the `MLX_ROOT` variable being set correctly to locate the library.
SOURCE: https://github.com/ml-explore/mlx/blob/main/examples/cmake_project/CMakeLists.txt#_snippet_2

LANGUAGE: CMake
CODE:
```
find_package(MLX CONFIG REQUIRED)
```

----------------------------------------

TITLE: Manually Setting MLX Root Directory in CMake (cmake)
DESCRIPTION: CMake code to manually specify the installation path of the MLX C++ library if it was installed to a non-standard location or CMake cannot find it automatically. Sets the `MLX_ROOT` variable to the specified path.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/dev/mlx_in_cpp.rst#_snippet_4

LANGUAGE: cmake
CODE:
```
set(MLX_ROOT "/path/to/mlx/")
```

----------------------------------------

TITLE: Configuring MLX Extension C++ Library
DESCRIPTION: This snippet defines the `mlx_ext` library, adds its C++ source file (`axpby.cpp`), includes its header directories, and links it publicly to the `mlx` library. This sets up the core C++ component of the extension.
SOURCE: https://github.com/ml-explore/mlx/blob/main/examples/extensions/CMakeLists.txt#_snippet_2

LANGUAGE: CMake
CODE:
```
# ----------------------------- Extensions -----------------------------

# Add library
add_library(mlx_ext)

# Add sources
target_sources(mlx_ext PUBLIC ${CMAKE_CURRENT_LIST_DIR}/axpby/axpby.cpp)

# Add include headers
target_include_directories(mlx_ext PUBLIC ${CMAKE_CURRENT_LIST_DIR})

# Link to mlx
target_link_libraries(mlx_ext PUBLIC mlx)
```

----------------------------------------

TITLE: Prepare Axpby GPU Evaluation
DESCRIPTION: This C++ function `Axpby::eval_gpu` initiates the GPU execution of the Axpby primitive. It retrieves input and output arrays, obtains the Metal device associated with the execution stream, allocates memory for the output array, and constructs the name of the specific Metal kernel to be used based on the output data type.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/dev/extensions.rst#_snippet_10

LANGUAGE: C++
CODE:
```
    /** Evaluate primitive on GPU */
    void Axpby::eval_gpu(
      const std::vector<array>& inputs,
      std::vector<array>& outputs) {
        // Prepare inputs
        assert(inputs.size() == 2);
        auto& x = inputs[0];
        auto& y = inputs[1];
        auto& out = outputs[0];

        // Each primitive carries the stream it should execute on
        // and each stream carries its device identifiers
        auto& s = stream();
        // We get the needed metal device using the stream
        auto& d = metal::device(s.device);

        // Allocate output memory
        out.set_data(allocator::malloc(out.nbytes()));

        // Resolve name of kernel
        std::ostringstream kname;
        kname << "axpby_" << "general_" << type_to_name(out);

        // Make sure the metal library is available

```

----------------------------------------

TITLE: Getting MLX Module Parameter Shapes
DESCRIPTION: Shows how to use mlx.utils.tree_map to apply a function (getting the shape) to every parameter in an mlx.nn.Module, resulting in a nested structure mirroring the parameters but containing shapes.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/python/nn.rst#_snippet_2

LANGUAGE: python
CODE:
```
from mlx.utils import tree_map
shapes = tree_map(lambda p: p.shape, mlp.parameters())
```

----------------------------------------

TITLE: Install Python Dependencies - Shell
DESCRIPTION: Installs required Python packages listed in requirements.txt using pip.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/README.md#_snippet_1

LANGUAGE: Shell
CODE:
```
pip install -r requirements.txt
```

----------------------------------------

TITLE: Install C++ API (Shell)
DESCRIPTION: Installs the built MLX C++ library and associated files using the `make install` command within the build directory.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/install.rst#_snippet_12

LANGUAGE: shell
CODE:
```
make install
```

----------------------------------------

TITLE: Performing In-Place Updates on MLX Array (Shell)
DESCRIPTION: Demonstrates modifying an element of an MLX array directly using indexing for an in-place update in the shell.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/usage/indexing.rst#_snippet_4

LANGUAGE: shell
CODE:
```
>>> a = mx.array([1, 2, 3])
>>> a[2] = 0
>>> a
array([1, 2, 0], dtype=int32)
```

----------------------------------------

TITLE: Faster Python API build (Shell)
DESCRIPTION: Builds the MLX Python API extensions in-place using `setup.py` after development dependencies are installed. Sets the parallel build level for CMake.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/install.rst#_snippet_6

LANGUAGE: shell
CODE:
```
CMAKE_BUILD_PARALLEL_LEVEL=8 python setup.py build_ext --inplace
```

----------------------------------------

TITLE: Run MLX C++ Train Program (bash)
DESCRIPTION: Executes the compiled C++ program 'train_mlp' located in the 'build' directory. This program imports and runs the model initialization and training functions exported by the 'train_mlp.py' script.
SOURCE: https://github.com/ml-explore/mlx/blob/main/examples/export/README.md#_snippet_6

LANGUAGE: bash
CODE:
```
./build/train_mlp
```

----------------------------------------

TITLE: Configure MLX C++ Build (bash)
DESCRIPTION: Configures the build environment for the C++ examples using CMake. Creates a 'build' directory and sets the build type to Release for optimized performance.
SOURCE: https://github.com/ml-explore/mlx/blob/main/examples/export/README.md#_snippet_1

LANGUAGE: bash
CODE:
```
cmake -B build -DCMAKE_BUILD_TYPE=Release
```

----------------------------------------

TITLE: Metal Kernel Source for Grid Sample VJP
DESCRIPTION: This Metal Shading Language (MSL) kernel source code implements the core logic for the `grid_sample` backward pass. It calculates the gradients for the input image (`x_grad`) and the sampling grid (`grid_grad`) based on the cotangent. It utilizes atomic operations (`atomic_fetch_add_explicit`) to safely accumulate gradients from multiple threads and includes a `simd_sum` optimization for efficiency.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/dev/custom_metal_kernels.rst#_snippet_8

LANGUAGE: metal
CODE:
```
uint elem = thread_position_in_grid.x;
int H = x_shape[1];
int W = x_shape[2];
int C = x_shape[3];
// Pad C to the nearest larger simdgroup size multiple
int C_padded = ceildiv(C, threads_per_simdgroup) * threads_per_simdgroup;

int gH = grid_shape[1];
int gW = grid_shape[2];

int w_stride = C;
int h_stride = W * w_stride;
int b_stride = H * h_stride;

uint grid_idx = elem / C_padded * 2;
float ix = ((grid[grid_idx] + 1) * W - 1) / 2;
float iy = ((grid[grid_idx + 1] + 1) * H - 1) / 2;

int ix_nw = floor(ix);
int iy_nw = floor(iy);

int ix_ne = ix_nw + 1;
int iy_ne = iy_nw;

int ix_sw = ix_nw;
int iy_sw = iy_nw + 1;

int ix_se = ix_nw + 1;
int iy_se = iy_nw + 1;

T nw = (ix_se - ix)    * (iy_se - iy);
T ne = (ix    - ix_sw) * (iy_sw - iy);
T sw = (ix_ne - ix)    * (iy    - iy_ne);
T se = (ix    - ix_nw) * (iy    - iy_nw);

int batch_idx = elem / C_padded / gH / gW * b_stride;
int channel_idx = elem % C_padded;
int base_idx = batch_idx + channel_idx;

T gix = T(0);
T giy = T(0);
if (channel_idx < C) {
    int cot_index = elem / C_padded * C + channel_idx;
    T cot = cotangent[cot_index];
    if (iy_nw >= 0 && iy_nw <= H - 1 && ix_nw >= 0 && ix_nw <= W - 1) {
        int offset = base_idx + iy_nw * h_stride + ix_nw * w_stride;
        atomic_fetch_add_explicit(&x_grad[offset], nw * cot, memory_order_relaxed);

        T I_nw = x[offset];
        gix -= I_nw * (iy_se - iy) * cot;
        giy -= I_nw * (ix_se - ix) * cot;
    }
    if (iy_ne >= 0 && iy_ne <= H - 1 && ix_ne >= 0 && ix_ne <= W - 1) {
        int offset = base_idx + iy_ne * h_stride + ix_ne * w_stride;
        atomic_fetch_add_explicit(&x_grad[offset], ne * cot, memory_order_relaxed);

        T I_ne = x[offset];
        gix += I_ne * (iy_sw - iy) * cot;
        giy -= I_ne * (ix - ix_sw) * cot;
    }
    if (iy_sw >= 0 && iy_sw <= H - 1 && ix_sw >= 0 && ix_sw <= W - 1) {
        int offset = base_idx + iy_sw * h_stride + ix_sw * w_stride;
        atomic_fetch_add_explicit(&x_grad[offset], sw * cot, memory_order_relaxed);

        T I_sw = x[offset];
        gix -= I_sw * (iy - iy_ne) * cot;
        giy += I_sw * (ix_ne - ix) * cot;
    }
    if (iy_se >= 0 && iy_se <= H - 1 && ix_se >= 0 && ix_se <= W - 1) {
        int offset = base_idx + iy_se * h_stride + ix_se * w_stride;
        atomic_fetch_add_explicit(&x_grad[offset], se * cot, memory_order_relaxed);

        T I_se = x[offset];
        gix += I_se * (iy - iy_nw) * cot;
        giy += I_se * (ix - ix_nw) * cot;
    }
}

T gix_mult = W / 2;
T giy_mult = H / 2;

// Reduce across each simdgroup first.
// This is much faster than relying purely on atomics.
gix = simd_sum(gix);
giy = simd_sum(giy);

if (thread_index_in_simdgroup == 0) {
    atomic_fetch_add_explicit(&grid_grad[grid_idx], gix * gix_mult, memory_order_relaxed);
    atomic_fetch_add_explicit(&grid_grad[grid_idx + 1], giy * giy_mult, memory_order_relaxed);
}
```

----------------------------------------

TITLE: C++ declaration for axpby operation
DESCRIPTION: This C++ code snippet shows the function signature for the `axpby` operation in the MLX C++ API. It takes two arrays, two float scalars, and an optional stream, with comments explaining the parameters and purpose.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/dev/extensions.rst#_snippet_1

LANGUAGE: C++
CODE:
```
/**
*  Scale and sum two vectors element-wise
*  z = alpha * x + beta * y
*
*  Use NumPy-style broadcasting between x and y
*  Inputs are upcasted to floats if needed
**/
array axpby(
    const array& x, // Input array x
    const array& y, // Input array y
    const float alpha, // Scaling factor for x
    const float beta, // Scaling factor for y
    StreamOrDevice s = {} // Stream on which to schedule the operation
);
```

----------------------------------------

TITLE: Generating Synthetic Linear Regression Data (Python)
DESCRIPTION: Generates synthetic data for linear regression, including true parameters, input features (design matrix), and noisy labels based on the true parameters and added Gaussian noise.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/examples/linear_regression.rst#_snippet_1

LANGUAGE: Python
CODE:
```
# True parameters
w_star = mx.random.normal((num_features,))

# Input examples (design matrix)
X = mx.random.normal((num_examples, num_features))

# Noisy labels
eps = 1e-2 * mx.random.normal((num_examples,))
y = X @ w_star + eps
```

----------------------------------------

TITLE: Build MLX C++ Example
DESCRIPTION: Builds the MLX C++ example project using CMake from the previously configured 'build' directory.
SOURCE: https://github.com/ml-explore/mlx/blob/main/examples/cmake_project/README.md#_snippet_2

LANGUAGE: bash
CODE:
```
cmake --build build
```

----------------------------------------

TITLE: Run MLX Python Eval Script (bash)
DESCRIPTION: Executes the Python script 'eval_mlp.py'. This script typically prepares data or exports necessary components (like model weights or functions) for the C++ evaluation program.
SOURCE: https://github.com/ml-explore/mlx/blob/main/examples/export/README.md#_snippet_3

LANGUAGE: bash
CODE:
```
python eval_mlp.py
```

----------------------------------------

TITLE: Run MLX Python Train Script (bash)
DESCRIPTION: Executes the Python script 'train_mlp.py'. This script is responsible for initializing the model and defining the training functions that will be used by the C++ training program.
SOURCE: https://github.com/ml-explore/mlx/blob/main/examples/export/README.md#_snippet_5

LANGUAGE: bash
CODE:
```
python train_mlp.py
```

----------------------------------------

TITLE: Configure MLX C++ Example Build
DESCRIPTION: Configures the build environment for the MLX C++ example using CMake, creating a build directory named 'build' and setting the build type to Release.
SOURCE: https://github.com/ml-explore/mlx/blob/main/examples/cmake_project/README.md#_snippet_1

LANGUAGE: bash
CODE:
```
cmake -B build -DCMAKE_BUILD_TYPE=Release
```

----------------------------------------

TITLE: Building Metal Library with CMake (CMake)
DESCRIPTION: This CMake snippet uses the 'mlx_build_metallib' function to compile the Metal sources into a '.metallib' target, which is then added as a dependency for the C++ extension library.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/dev/extensions.rst#_snippet_17

LANGUAGE: cmake
CODE:
```
# Build metallib
if(MLX_BUILD_METAL)

mlx_build_metallib(
    TARGET mlx_ext_metallib
    TITLE mlx_ext
    SOURCES ${CMAKE_CURRENT_LIST_DIR}/axpby/axpby.metal
    INCLUDE_DIRS ${PROJECT_SOURCE_DIR} ${MLX_INCLUDE_DIRS}
    OUTPUT_DIRECTORY ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}
)

add_dependencies(
    mlx_ext
    mlx_ext_metallib
)

endif()
```

----------------------------------------

TITLE: Install Python API for development (Shell)
DESCRIPTION: Installs the MLX Python API in editable mode with development dependencies from the local source directory using pip. Sets the parallel build level for CMake.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/install.rst#_snippet_5

LANGUAGE: shell
CODE:
```
CMAKE_BUILD_PARALLEL_LEVEL=8 pip install -e ".[dev]"
```

----------------------------------------

TITLE: Finding MLX via Python Installation in CMake (cmake)
DESCRIPTION: CMake code to locate the MLX installation directory when MLX was installed via pip. It finds the Python interpreter and development modules, then executes a Python command to get the MLX CMake directory path, storing it in the `MLX_ROOT` variable.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/dev/mlx_in_cpp.rst#_snippet_3

LANGUAGE: cmake
CODE:
```
find_package(
  Python 3.9
  COMPONENTS Interpreter Development.Module
  REQUIRED)
execute_process(
  COMMAND "${Python_EXECUTABLE}" -m mlx --cmake-dir
  OUTPUT_STRIP_TRAILING_WHITESPACE
  OUTPUT_VARIABLE MLX_ROOT)
```

----------------------------------------

TITLE: Initialize Arrays for Naive Vector Addition Example (Python)
DESCRIPTION: Initializes two MLX arrays with random uniform values to set up a basic example demonstrating a naive approach to vector addition before introducing `vmap`. The function definition is incomplete in the source.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/usage/function_transforms.rst#_snippet_5

LANGUAGE: python
CODE:
```
xs = mx.random.uniform(shape=(4096, 100))
ys = mx.random.uniform(shape=(100, 4096))

def naive_add(xs, ys):
```

----------------------------------------

TITLE: Configure C++ build for binary size minimization (Shell)
DESCRIPTION: Configures the CMake build with options to minimize binary size, including setting build type to `MinSizeRel`, enabling shared libraries, disabling CPU backend, safetensors, GGUF, and enabling Metal JIT.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/install.rst#_snippet_15

LANGUAGE: shell
CODE:
```
cmake .. \\
  -DCMAKE_BUILD_TYPE=MinSizeRel \\
  -DBUILD_SHARED_LIBS=ON \\
  -DMLX_BUILD_CPU=OFF \\
  -DMLX_BUILD_SAFETENSORS=OFF \\
  -DMLX_BUILD_GGUF=OFF \\
  -DMLX_METAL_JIT=ON
```

----------------------------------------

TITLE: Disabling Accelerate Build in MLX CMake
DESCRIPTION: This snippet conditionally disables the Accelerate framework build for MLX, typically used when specific build configurations or platforms do not require or support it. It ensures that the MLX_BUILD_ACCELERATE option is set to OFF.
SOURCE: https://github.com/ml-explore/mlx/blob/main/CMakeLists.txt#_snippet_11

LANGUAGE: CMake
CODE:
```
set(MLX_BUILD_ACCELERATE OFF)
endif()
```

----------------------------------------

TITLE: Run C++ API tests (Shell)
DESCRIPTION: Executes the tests for the MLX C++ API using the `make test` command within the build directory.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/install.rst#_snippet_11

LANGUAGE: shell
CODE:
```
make test
```

----------------------------------------

TITLE: Setting CMake Minimum Version and Project Details - CMake
DESCRIPTION: This snippet sets the minimum required CMake version to 3.27, defines the project 'example' with C++ as the language, and configures the C++ standard to C++17, ensuring it's strictly required for compilation.
SOURCE: https://github.com/ml-explore/mlx/blob/main/examples/cmake_project/CMakeLists.txt#_snippet_0

LANGUAGE: CMake
CODE:
```
cmake_minimum_required(VERSION 3.27)

project(example LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
```

----------------------------------------

TITLE: Building C++ Extension Library with CMake (CMake)
DESCRIPTION: This CMake snippet defines a static library 'mlx_ext', adds its source files and include directories, and links it against the MLX library.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/dev/extensions.rst#_snippet_16

LANGUAGE: cmake
CODE:
```
# Add library
add_library(mlx_ext)

# Add sources
target_sources(
    mlx_ext
    PUBLIC
    ${CMAKE_CURRENT_LIST_DIR}/axpby/axpby.cpp
)

# Add include headers
target_include_directories(
    mlx_ext PUBLIC ${CMAKE_CURRENT_LIST_DIR}
)

# Link to mlx
target_link_libraries(mlx_ext PUBLIC mlx)
```

----------------------------------------

TITLE: Configuring CPU Backend (Accelerate, OpenBLAS, LAPACK/BLAS) (CMake)
DESCRIPTION: This comprehensive block manages the CPU backend configuration for MLX. It first attempts to find and use Apple's Accelerate framework. If Accelerate is not available or MLX_BUILD_BLAS_FROM_SOURCE is set, it fetches and builds OpenBLAS from source. Otherwise, it searches for and links against system-wide LAPACK and BLAS libraries, with special handling for macOS to prefer Homebrew's OpenBLAS.
SOURCE: https://github.com/ml-explore/mlx/blob/main/CMakeLists.txt#_snippet_10

LANGUAGE: CMake
CODE:
```
if(MLX_BUILD_CPU)
  find_library(ACCELERATE_LIBRARY Accelerate)
  if(ACCELERATE_LIBRARY)
    message(STATUS "Accelerate found ${ACCELERATE_LIBRARY}")
    set(MLX_BUILD_ACCELERATE ON)
  else()
    message(STATUS "Accelerate or arm neon not found, using default backend.")
    set(MLX_BUILD_ACCELERATE OFF)
  endif()

  if(MLX_BUILD_ACCELERATE)
    target_link_libraries(mlx PUBLIC ${ACCELERATE_LIBRARY})
    add_compile_definitions(MLX_USE_ACCELERATE)
    add_compile_definitions(ACCELERATE_NEW_LAPACK)
  elseif(MLX_BUILD_BLAS_FROM_SOURCE)
    # Download and build OpenBLAS from source code.
    FetchContent_Declare(
      openblas
      GIT_REPOSITORY https://github.com/OpenMathLib/OpenBLAS.git
      GIT_TAG v0.3.28
      EXCLUDE_FROM_ALL)
    set(BUILD_STATIC_LIBS ON) # link statically
    set(NOFORTRAN ON) # msvc has no fortran compiler
    FetchContent_MakeAvailable(openblas)
    target_link_libraries(mlx PRIVATE openblas)
    target_include_directories(
      mlx PRIVATE "${openblas_SOURCE_DIR}/lapack-netlib/LAPACKE/include"
                  "${CMAKE_BINARY_DIR}/generated" "${CMAKE_BINARY_DIR}")
  else()
    if(${CMAKE_HOST_APPLE})
      # The blas shipped in macOS SDK is not supported, search homebrew for
      # openblas instead.
      set(BLA_VENDOR OpenBLAS)
      set(LAPACK_ROOT
          "${LAPACK_ROOT};$ENV{LAPACK_ROOT};/usr/local/opt/openblas")
    endif()
    # Search and link with lapack.
    find_package(LAPACK REQUIRED)
    if(NOT LAPACK_FOUND)
      message(FATAL_ERROR "Must have LAPACK installed")
    endif()
    find_path(LAPACK_INCLUDE_DIRS lapacke.h /usr/include /usr/local/include
              /usr/local/opt/openblas/include)
    message(STATUS "Lapack lib " ${LAPACK_LIBRARIES})
    message(STATUS "Lapack include " ${LAPACK_INCLUDE_DIRS})
    target_include_directories(mlx PRIVATE ${LAPACK_INCLUDE_DIRS})
    target_link_libraries(mlx PRIVATE ${LAPACK_LIBRARIES})
    # List blas after lapack otherwise we may accidentally incldue an old
    # version of lapack.h from the include dirs of blas.
    find_package(BLAS REQUIRED)
    if(NOT BLAS_FOUND)
      message(FATAL_ERROR "Must have BLAS installed")
    endif()
    # TODO find a cleaner way to do this
    find_path(BLAS_INCLUDE_DIRS cblas.h /usr/include /usr/local/include
              $ENV{BLAS_HOME}/include)
    message(STATUS "Blas lib " ${BLAS_LIBRARIES})
    message(STATUS "Blas include " ${BLAS_INCLUDE_DIRS})
    target_include_directories(mlx PRIVATE ${BLAS_INCLUDE_DIRS})
    target_link_libraries(mlx PRIVATE ${BLAS_LIBRARIES})
  endif()
else()
```

----------------------------------------

TITLE: Defining a 4-Node Ring Hostfile (JSON)
DESCRIPTION: This JSON snippet defines a hostfile for a 4-node ring topology. Each object represents a node with its SSH hostname and a list of IP addresses it will listen on. This file is used by `mlx.launch` to coordinate distributed processes.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/usage/distributed.rst#_snippet_11

LANGUAGE: json
CODE:
```
[
    {"ssh": "hostname1", "ips": ["123.123.123.1"]},
    {"ssh": "hostname2", "ips": ["123.122.122.2"]},
    {"ssh": "hostname3", "ips": ["123.121.121.3"]},
    {"ssh": "hostname4", "ips": ["123.120.120.4"]}
]
```

----------------------------------------

TITLE: Finding Python and MLX Root Directory - CMake
DESCRIPTION: This snippet locates Python 3.9, specifically its interpreter and development modules, which are required for the project. It then executes a Python command to find the MLX CMake directory, storing its path in the `MLX_ROOT` variable for subsequent use.
SOURCE: https://github.com/ml-explore/mlx/blob/main/examples/cmake_project/CMakeLists.txt#_snippet_1

LANGUAGE: CMake
CODE:
```
find_package(
  Python 3.9
  COMPONENTS Interpreter Development.Module
  REQUIRED)
execute_process(
  COMMAND "${Python_EXECUTABLE}" -m mlx --cmake-dir
  OUTPUT_STRIP_TRAILING_WHITESPACE
  OUTPUT_VARIABLE MLX_ROOT)
```

----------------------------------------

TITLE: Initial CMakeLists.txt Setup (cmake)
DESCRIPTION: Sets up the basic structure for a CMake project (`CMakeLists.txt`). It specifies the minimum required CMake version, defines the project name and language (C++), and sets the C++ standard to 17, requiring it.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/dev/mlx_in_cpp.rst#_snippet_2

LANGUAGE: cmake
CODE:
```
cmake_minimum_required(VERSION 3.27)

project(example LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
```

----------------------------------------

TITLE: Setting CMake Build Standards and Paths
DESCRIPTION: This section configures general CMake build settings, including the module path, C++ standard (C++17), requiring the standard, enabling position-independent code, and suppressing install messages. These settings ensure a consistent and modern build environment for the MLX project.
SOURCE: https://github.com/ml-explore/mlx/blob/main/CMakeLists.txt#_snippet_1

LANGUAGE: CMake
CODE:
```
# ----------------------------- Setup -----------------------------
set(CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake")
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)
set(CMAKE_INSTALL_MESSAGE NEVER)
```

----------------------------------------

TITLE: Configuring CMake Build (bash)
DESCRIPTION: Executes CMake to configure the build system. It creates a build directory named `build`, specifies the source directory (current directory), and sets the build type to `Release` for optimized compilation.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/dev/mlx_in_cpp.rst#_snippet_7

LANGUAGE: bash
CODE:
```
cmake -B build -DCMAKE_BUILD_TYPE=Release
```

----------------------------------------

TITLE: Build MLX C++ Extensions - Shell
DESCRIPTION: Builds the C++ extensions for the MLX project using setup.py. The -j8 flag specifies parallel compilation with 8 jobs, and --inplace places the built extensions in the source directory.
SOURCE: https://github.com/ml-explore/mlx/blob/main/examples/extensions/README.md#_snippet_2

LANGUAGE: Shell
CODE:
```
python setup.py build_ext -j8 --inplace
```

----------------------------------------

TITLE: Visualizing Thunderbolt Ring with mlx.distributed_config (Shell)
DESCRIPTION: These shell commands use `mlx.distributed_config` to generate a DOT format representation of the discovered Thunderbolt ring topology. The output is piped to `dot` to create a PNG image, which is then opened.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/usage/distributed.rst#_snippet_13

LANGUAGE: shell
CODE:
```
mlx.distributed_config --verbose --hosts host1,host2,host3,host4 --dot >ring.dot
dot -Tpng ring.dot >ring.png
open ring.png
```

----------------------------------------

TITLE: Build MLX C++ Examples (bash)
DESCRIPTION: Compiles the MLX C++ examples based on the configuration generated by the previous CMake command. The compiled executables will be placed in the 'build' directory.
SOURCE: https://github.com/ml-explore/mlx/blob/main/examples/export/README.md#_snippet_2

LANGUAGE: bash
CODE:
```
cmake --build build
```

----------------------------------------

TITLE: Specify Xcode installation path (Shell)
DESCRIPTION: Sets the `DEVELOPER_DIR` environment variable to point to a specific Xcode installation, useful when multiple versions are present.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/install.rst#_snippet_13

LANGUAGE: shell
CODE:
```
export DEVELOPER_DIR="/path/to/Xcode.app/Contents/Developer/"
```

----------------------------------------

TITLE: Generated Metal Kernel Signature for Elementwise Exp
DESCRIPTION: Shows the C++ Metal kernel signature that MLX automatically generates based on the Python `metal_kernel` definition. It illustrates how input arrays, output arrays, template parameters, and Metal attributes are mapped to kernel function arguments.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/dev/custom_metal_kernels.rst#_snippet_1

LANGUAGE: cpp
CODE:
```
template <typename T>
[[kernel]] void custom_kernel_myexp_float(
  const device float16_t* inp [[buffer(0)]],
  device float16_t* out [[buffer(1)]],
  uint3 thread_position_in_grid [[thread_position_in_grid]]) {

        uint elem = thread_position_in_grid.x;
        T tmp = inp[elem];
        out[elem] = metal::exp(tmp);

}

template [[host_name("custom_kernel_myexp_float")]] [[kernel]] decltype(custom_kernel_myexp_float<float>) custom_kernel_myexp_float<float>;
```

----------------------------------------

TITLE: Testing Element-wise Operation MLX Python
DESCRIPTION: A small test case demonstrating the usage of an element-wise function (presumably exp_elementwise, not shown) with MLX tensors, including creating a non-contiguous tensor and asserting the result against mx.exp.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/dev/custom_metal_kernels.rst#_snippet_3

LANGUAGE: python
CODE:
```
a = mx.random.normal(shape=(4, 16)).astype(mx.float16)
# make non-contiguous
a = a[::2]
b = exp_elementwise(a)
assert mx.allclose(b, mx.exp(a))
```

----------------------------------------

TITLE: Clone MLX repository for Python build (Shell)
DESCRIPTION: Clones the MLX GitHub repository and changes the current directory into the newly created `mlx` directory. This is the first step for building the Python API from source.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/install.rst#_snippet_3

LANGUAGE: shell
CODE:
```
git clone git@github.com:ml-explore/mlx.git mlx && cd mlx
```

----------------------------------------

TITLE: Clone MLX repository for C++ build (Shell)
DESCRIPTION: Clones the MLX GitHub repository and changes the current directory into the newly created `mlx` directory. This is the first step for building the C++ API from source.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/install.rst#_snippet_9

LANGUAGE: shell
CODE:
```
git clone git@github.com:ml-explore/mlx.git mlx && cd mlx
```

----------------------------------------

TITLE: Configuring and Installing MLX CMake Package
DESCRIPTION: This comprehensive snippet sets up and installs CMake configuration files for MLX. It defines paths for build and version config files, exports MLXTargets, writes a version file, configures the main package config file from a template, and installs all generated CMake files and modules.
SOURCE: https://github.com/ml-explore/mlx/blob/main/CMakeLists.txt#_snippet_21

LANGUAGE: CMake
CODE:
```
# Install cmake config
set(MLX_CMAKE_BUILD_CONFIG ${CMAKE_BINARY_DIR}/MLXConfig.cmake)
set(MLX_CMAKE_BUILD_VERSION_CONFIG ${CMAKE_BINARY_DIR}/MLXConfigVersion.cmake)
set(MLX_CMAKE_INSTALL_MODULE_DIR share/cmake/MLX)

install(
  EXPORT MLXTargets
  FILE MLXTargets.cmake
  DESTINATION ${MLX_CMAKE_INSTALL_MODULE_DIR})

include(CMakePackageConfigHelpers)

write_basic_package_version_file(
  ${MLX_CMAKE_BUILD_VERSION_CONFIG}
  COMPATIBILITY SameMajorVersion
  VERSION ${MLX_VERSION})

configure_package_config_file(
  ${CMAKE_CURRENT_LIST_DIR}/mlx.pc.in ${MLX_CMAKE_BUILD_CONFIG}
  INSTALL_DESTINATION ${MLX_CMAKE_INSTALL_MODULE_DIR}
  NO_CHECK_REQUIRED_COMPONENTS_MACRO
  PATH_VARS CMAKE_INSTALL_LIBDIR CMAKE_INSTALL_INCLUDEDIR
            MLX_CMAKE_INSTALL_MODULE_DIR)

install(FILES ${MLX_CMAKE_BUILD_CONFIG} ${MLX_CMAKE_BUILD_VERSION_CONFIG}
        DESTINATION ${MLX_CMAKE_INSTALL_MODULE_DIR})

install(DIRECTORY ${CMAKE_MODULE_PATH}/
        DESTINATION ${MLX_CMAKE_INSTALL_MODULE_DIR})
```

----------------------------------------

TITLE: Initializing Input Arrays for Mixed Device Example (MLX Python)
DESCRIPTION: Initializes two arrays with random uniform values, intended as input arguments for the `fun` function example to demonstrate the performance benefits of using different devices for different parts of the computation.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/usage/unified_memory.rst#_snippet_4

LANGUAGE: python
CODE:
```
a = mx.random.uniform(shape=(4096, 512))
b = mx.random.uniform(shape=(512, 4))
```

----------------------------------------

TITLE: Conditional MLX Metal JIT Kernel Inclusion
DESCRIPTION: This CMake block conditionally includes additional Metal JIT kernels based on the `MLX_METAL_JIT` build option. If enabled, it adds `jit_kernels.cpp` and registers a wide range of advanced kernels for JIT compilation, including FFT, LogSumExp, Softmax, Scan, Sort, various reduction types, and specialized Steel GEMM/Conv kernels. Otherwise, it includes `nojit_kernels.cpp`, indicating a non-JIT build path.
SOURCE: https://github.com/ml-explore/mlx/blob/main/mlx/backend/metal/CMakeLists.txt#_snippet_2

LANGUAGE: CMake
CODE:
```
if(MLX_METAL_JIT)
  target_sources(mlx PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/jit_kernels.cpp)
  make_jit_source(arange)
  make_jit_source(copy)
  make_jit_source(unary)
  make_jit_source(binary)
  make_jit_source(binary_two)
  make_jit_source(fft kernels/fft/radix.h kernels/fft/readwrite.h)
  make_jit_source(logsumexp)
  make_jit_source(ternary)
  make_jit_source(softmax)
  make_jit_source(scan)
  make_jit_source(sort)
  make_jit_source(
    reduce kernels/reduction/reduce_all.h kernels/reduction/reduce_col.h
    kernels/reduction/reduce_row.h kernels/reduction/reduce_init.h)
  make_jit_source(
    steel/gemm/gemm kernels/steel/utils.h kernels/steel/gemm/loader.h
    kernels/steel/gemm/mma.h kernels/steel/gemm/params.h
    kernels/steel/gemm/transforms.h)
  make_jit_source(steel/gemm/kernels/steel_gemm_fused)
  make_jit_source(steel/gemm/kernels/steel_gemm_masked kernels/steel/defines.h)
  make_jit_source(steel/gemm/kernels/steel_gemm_gather)
  make_jit_source(steel/gemm/kernels/steel_gemm_splitk)
  make_jit_source(
    steel/conv/conv
    kernels/steel/utils.h
    kernels/steel/defines.h
    kernels/steel/gemm/mma.h
    kernels/steel/gemm/transforms.h
    kernels/steel/conv/params.h
    kernels/steel/conv/loader.h
    kernels/steel/conv/loaders/loader_channel_l.h
    kernels/steel/conv/loaders/loader_channel_n.h)
  make_jit_source(steel/conv/kernels/steel_conv)
  make_jit_source(steel/conv/kernels/steel_conv_general kernels/steel/defines.h
                  kernels/steel/conv/loaders/loader_general.h)
  make_jit_source(quantized)
  make_jit_source(gemv_masked)
else()
  target_sources(mlx PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/nojit_kernels.cpp)
endif()
```

----------------------------------------

TITLE: Verify CMake Host Processor Architecture (Shell)
DESCRIPTION: Runs CMake's system information command and filters the output to check the host processor architecture detected by CMake, ensuring it matches the desired build architecture (e.g., arm64).
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/install.rst#_snippet_19

LANGUAGE: shell
CODE:
```
$ cmake --system-information | grep CMAKE_HOST_SYSTEM_PROCESSOR
```

----------------------------------------

TITLE: Running the Compiled MLX Example (bash)
DESCRIPTION: Executes the compiled C++ example program located in the `build` directory. This runs the program that uses MLX to perform array addition and print the result.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/dev/mlx_in_cpp.rst#_snippet_9

LANGUAGE: bash
CODE:
```
./build/example
```

----------------------------------------

TITLE: Install Xcode Command Line Tools (Shell)
DESCRIPTION: Installs the essential command line tools from Xcode, which are necessary for compiling and linking code that uses system frameworks like Metal.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/install.rst#_snippet_16

LANGUAGE: shell
CODE:
```
xcode-select --install
```

----------------------------------------

TITLE: Build Documentation HTML - Shell
DESCRIPTION: Runs Doxygen to generate documentation and then uses Make to build the HTML output.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/README.md#_snippet_2

LANGUAGE: Shell
CODE:
```
doxygen && make html
```

----------------------------------------

TITLE: Example Input Shapes for grid_sample MLX Python
DESCRIPTION: Defines example shapes for the input tensor x and the grid tensor grid to illustrate a typical use case for the grid_sample function, often used for performance benchmarking.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/dev/custom_metal_kernels.rst#_snippet_6

LANGUAGE: python
CODE:
```
x.shape = (8, 1024, 1024, 64)
grid.shape = (8, 256, 256, 2)
```

----------------------------------------

TITLE: Installing MLX Library and Targets
DESCRIPTION: This snippet defines the installation rules for the mlx library. It exports MLXTargets for use by other projects and specifies destinations for library, archive, runtime, and include files according to standard GNU installation directories.
SOURCE: https://github.com/ml-explore/mlx/blob/main/CMakeLists.txt#_snippet_18

LANGUAGE: CMake
CODE:
```
# ----------------------------- Installation -----------------------------
include(GNUInstallDirs)

# Install library
install(
  TARGETS mlx
  EXPORT MLXTargets
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
  INCLUDES
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})
```

----------------------------------------

TITLE: Defining Benchmark Build Function - CMake
DESCRIPTION: This CMake function, `build_benchmark`, encapsulates the logic for compiling a single benchmark source file into an executable. It automatically names the target after the source file and links it against the `mlx` library, simplifying the addition of new benchmarks.
SOURCE: https://github.com/ml-explore/mlx/blob/main/benchmarks/cpp/CMakeLists.txt#_snippet_0

LANGUAGE: CMake
CODE:
```
function(build_benchmark SRCFILE)
  get_filename_component(src_name ${SRCFILE} NAME_WE)
  set(target "${src_name}")
  add_executable(${target} ${SRCFILE})
  target_link_libraries(${target} PRIVATE mlx)
endfunction(build_benchmark)
```

----------------------------------------

TITLE: Importing Core MLX Modules for Fast Operations (Python)
DESCRIPTION: This snippet imports fundamental MLX core components (`array`, `Dtype`, `Device`, `Stream`) and standard Python typing utilities. These imports are common for modules focusing on optimized or 'fast' operations within the MLX framework, providing basic data structures and type hints.
SOURCE: https://github.com/ml-explore/mlx/blob/main/python/mlx/_stub_patterns.txt#_snippet_1

LANGUAGE: Python
CODE:
```
from mlx.core import array, Dtype, Device, Stream
from typing import Sequence, Optional, Union
```

----------------------------------------

TITLE: Run MLX C++ Eval Program (bash)
DESCRIPTION: Executes the compiled C++ program 'eval_mlp' located in the 'build' directory. This program imports and utilizes the components exported by the 'eval_mlp.py' script to perform evaluation.
SOURCE: https://github.com/ml-explore/mlx/blob/main/examples/export/README.md#_snippet_4

LANGUAGE: bash
CODE:
```
./build/eval_mlp
```

----------------------------------------

TITLE: Define Strided Elementwise Exp Metal Kernel in Python
DESCRIPTION: Defines a Python function `exp_elementwise` that creates a custom Metal kernel capable of handling strided input arrays. It uses the `elem_to_loc` utility within the Metal source code to calculate the correct memory location based on shape and strides, avoiding the default row-contiguous copy.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/dev/custom_metal_kernels.rst#_snippet_2

LANGUAGE: python
CODE:
```
def exp_elementwise(a: mx.array):
    source = """
        uint elem = thread_position_in_grid.x;
        // Utils from `mlx/backend/metal/kernels/utils.h` are automatically included
        uint loc = elem_to_loc(elem, inp_shape, inp_strides, inp_ndim);
        T tmp = inp[loc];
        // Output arrays are always row contiguous
        out[elem] = metal::exp(tmp);
    """

    kernel = mx.fast.metal_kernel(
        name="myexp_strided",
        input_names=["inp"],
        output_names=["out"],
        source=source
    )
    outputs = kernel(
        inputs=[a],
        template=[("T", mx.float32)],
        grid=(a.size, 1, 1),
        threadgroup=(256, 1, 1),
        output_shapes=[a.shape],
        output_dtypes=[a.dtype],
        ensure_row_contiguous=False,
    )
```

----------------------------------------

TITLE: Integrating NVTX Library (CMake)
DESCRIPTION: This snippet integrates a fixed version (v3.1.1) of the NVTX (NVIDIA Tools Extension) library using `FetchContent`. It fetches the library from GitHub and links it publicly to the `mlx` target, enabling profiling capabilities.
SOURCE: https://github.com/ml-explore/mlx/blob/main/mlx/backend/cuda/CMakeLists.txt#_snippet_5

LANGUAGE: CMake
CODE:
```
FetchContent_Declare(
  nvtx3
  GIT_REPOSITORY https://github.com/NVIDIA/NVTX.git
  GIT_TAG v3.1.1
  GIT_SHALLOW TRUE
  SOURCE_SUBDIR c EXCLUDE_FROM_ALL)
FetchContent_MakeAvailable(nvtx3)
target_link_libraries(mlx PUBLIC $<BUILD_INTERFACE:nvtx3-cpp>)
```

----------------------------------------

TITLE: Verify Shell Architecture (Shell)
DESCRIPTION: Executes the 'uname -p' command to check the processor architecture under which the current shell is running. This helps confirm if the terminal is running natively (arm) or via Rosetta (x86).
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/install.rst#_snippet_18

LANGUAGE: shell
CODE:
```
$ uname -p
```

----------------------------------------

TITLE: Displaying Full Name with Filters in Jinja2
DESCRIPTION: This Jinja2 expression displays the value of the 'fullname' variable. It applies the 'escape' filter to HTML-escape the output and the 'underline' filter (likely a custom filter in this Sphinx context) for formatting.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/_templates/module-base-class.rst#_snippet_0

LANGUAGE: Jinja2
CODE:
```
{{ fullname | escape | underline}}
```

----------------------------------------

TITLE: Configuring MLX Metal Kernel Path and Subdirectory
DESCRIPTION: This CMake snippet sets the `MLX_METAL_PATH` variable to the binary directory's `kernels/` subdirectory if it's not already defined, providing a default location for Metal kernels. It then includes the `kernels` subdirectory, allowing CMake to process its `CMakeLists.txt` file and integrate kernel-related build configurations into the project.
SOURCE: https://github.com/ml-explore/mlx/blob/main/mlx/backend/metal/CMakeLists.txt#_snippet_4

LANGUAGE: CMake
CODE:
```
if(NOT MLX_METAL_PATH)
  set(MLX_METAL_PATH ${CMAKE_CURRENT_BINARY_DIR}/kernels/)
endif()

add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/kernels)
```

----------------------------------------

TITLE: Conditional MLX Build Options (Tests, Examples, Benchmarks)
DESCRIPTION: This snippet includes conditional blocks for building tests, C++ examples, and C++ benchmarks for MLX. Each block checks a specific MLX_BUILD_ variable and, if true, includes the relevant CMake subdirectory, with CTest included for tests.
SOURCE: https://github.com/ml-explore/mlx/blob/main/CMakeLists.txt#_snippet_17

LANGUAGE: CMake
CODE:
```
if(MLX_BUILD_TESTS)
  include(CTest)
  add_subdirectory(${CMAKE_CURRENT_LIST_DIR}/tests)
endif()

if(MLX_BUILD_EXAMPLES)
  add_subdirectory(${CMAKE_CURRENT_LIST_DIR}/examples/cpp)
endif()

if(MLX_BUILD_BENCHMARKS)
  add_subdirectory(${CMAKE_CURRENT_LIST_DIR}/benchmarks/cpp)
endif()
```

----------------------------------------

TITLE: Conditionally Building Metal Library for MLX Extension
DESCRIPTION: This conditional block builds a Metal library (`mlx_ext_metallib`) if `MLX_BUILD_METAL` is enabled. It compiles `axpby.metal` with specified include directories and outputs the library to the standard output directory, adding it as a dependency for `mlx_ext`.
SOURCE: https://github.com/ml-explore/mlx/blob/main/examples/extensions/CMakeLists.txt#_snippet_3

LANGUAGE: CMake
CODE:
```
# ----------------------------- Metal -----------------------------

# Build metallib
if(MLX_BUILD_METAL)
  mlx_build_metallib(
    TARGET
    mlx_ext_metallib
    TITLE
    mlx_ext
    SOURCES
    ${CMAKE_CURRENT_LIST_DIR}/axpby/axpby.metal
    INCLUDE_DIRS
    ${PROJECT_SOURCE_DIR}
    ${MLX_INCLUDE_DIRS}
    OUTPUT_DIRECTORY
    ${CMAKE_LIBRARY_OUTPUT_DIRECTORY})

  add_dependencies(mlx_ext mlx_ext_metallib)

endif()
```

----------------------------------------

TITLE: Set Active Xcode Developer Directory (Shell)
DESCRIPTION: Configures the system to use the specified path as the active developer directory, ensuring that development tools are correctly located.
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/install.rst#_snippet_17

LANGUAGE: shell
CODE:
```
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
```

----------------------------------------

TITLE: Conditional Check for Attributes in Jinja2
DESCRIPTION: This Jinja2 tag starts a conditional block that renders its content only if the 'attributes' variable is evaluated as true (e.g., it's not empty, null, or false).
SOURCE: https://github.com/ml-explore/mlx/blob/main/docs/src/_templates/module-base-class.rst#_snippet_4

LANGUAGE: Jinja2
CODE:
```
{% if attributes %}
```

----------------------------------------

TITLE: Determining MLX Project Version (CMake)
DESCRIPTION: This snippet determines the MLX project version. If `MLX_VERSION` is not pre-defined, it reads the version components (major, minor, patch) from `mlx/version.h` and constructs `MLX_PROJECT_VERSION`. Otherwise, it extracts the version from the existing `MLX_VERSION` variable. It also sets the minimum CMake version and declares the project with its languages and version.
SOURCE: https://github.com/ml-explore/mlx/blob/main/CMakeLists.txt#_snippet_0

LANGUAGE: CMake
CODE:
```
cmake_minimum_required(VERSION 3.25)

if(NOT MLX_VERSION)
  file(STRINGS "mlx/version.h" _mlx_h_version REGEX "^#define MLX_VERSION_.*$")
  string(REGEX MATCH "#define MLX_VERSION_MAJOR ([0-9]+)" _ "${_mlx_h_version}")
  set(_major ${CMAKE_MATCH_1})
  string(REGEX MATCH "#define MLX_VERSION_MINOR ([0-9]+)" _ "${_mlx_h_version}")
  set(_minor ${CMAKE_MATCH_1})
  string(REGEX MATCH "#define MLX_VERSION_PATCH ([0-9]+)" _ "${_mlx_h_version}")
  set(_patch ${CMAKE_MATCH_1})
  set(MLX_PROJECT_VERSION "${_major}.${_minor}.${_patch}")
  set(MLX_VERSION ${MLX_PROJECT_VERSION})
else()
  string(REGEX REPLACE "^([0-9]+\.[0-9]+\.[0-9]+).*" "\\1" MLX_PROJECT_VERSION
                       ${MLX_VERSION})
endif()

project(
  mlx
  LANGUAGES C CXX
  VERSION ${MLX_PROJECT_VERSION})
```

TITLE: Tools Data Format Example (Expanded) - JSONL
DESCRIPTION: This JSONL example provides a more verbose representation of the 'tools' data format, detailing the structure for specifying messages involving tool calls and the definitions of the available tools, including function parameters.
SOURCE: https://github.com/ml-explore/mlx-lm/blob/main/mlx_lm/LORA.md#_snippet_11

LANGUAGE: jsonl
CODE:
```
{
    "messages": [
        { "role": "user", "content": "What is the weather in San Francisco?" },
        {
            "role": "assistant",
            "tool_calls": [
                {
                    "id": "call_id",
                    "type": "function",
                    "function": {
                        "name": "get_current_weather",
                        "arguments": "{\"location\": \"San Francisco, USA\", \"format\": \"celsius\"}"
                    }
                }
            ]
        }
    ],
    "tools": [
        {
            "type": "function",
            "function": {
                "name": "get_current_weather",
                "description": "Get the current weather",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "location": {
                            "type": "string",
                            "description": "The city and country, eg. San Francisco, USA"
                        },
                        "format": { "type": "string", "enum": ["celsius", "fahrenheit"] }
                    },
                    "required": ["location", "format"]
                }
            }
        }
    ]
}
```

----------------------------------------

TITLE: Configuring - Multiple Hugging Face Datasets - YAML
DESCRIPTION: This YAML snippet illustrates how to specify a list of Hugging Face datasets for MLX LM training. Each entry in the list defines a dataset `path`, optional `train_split` and `valid_split` arguments using dataset slicing syntax, and maps the relevant feature keys (e.g., `prompt_feature`, `completion_feature`, `chat_feature`). This allows combining data from different sources.
SOURCE: https://github.com/ml-explore/mlx-lm/blob/main/mlx_lm/LORA.md#_snippet_17

LANGUAGE: YAML
CODE:
```
hf_dataset:
  - path: "Open-Orca/OpenOrca"
    train_split: "train[:90%]"
    valid_split: "train[-10%:]"
    prompt_feature: "question"
    completion_feature: "response"
  - path: "trl-lib/ultrafeedback_binarized"
    train_split: "train[:90%]"
    valid_split: "train[-10%:]"
    chat_feature: "chosen"
```

----------------------------------------

TITLE: Running - MLX LM LoRA Finetuning - Shell
DESCRIPTION: This shell command executes the `mlx_lm.lora` script to fine-tune a model using the LoRA method. It specifies the base model (`mistralai/Mistral-7B-v0.1`), enables training (`--train`), and includes arguments (`--batch-size 1`, `--num-layers 4`, `--data wikisql`) to reduce memory usage for systems with limited RAM (e.g., 32GB). This command requires MLX LM and dependencies to be installed.
SOURCE: https://github.com/ml-explore/mlx-lm/blob/main/mlx_lm/LORA.md#_snippet_18

LANGUAGE: Shell
CODE:
```
mlx_lm.lora \
    --model mistralai/Mistral-7B-v0.1 \
    --train \
    --batch-size 1 \
    --num-layers 4 \
    --data wikisql
```

----------------------------------------

TITLE: Fusing and Uploading Model to Hugging Face Hub - Shell
DESCRIPTION: This command uses `mlx_lm.fuse` to merge adapters into the base model and then uploads the resulting fused model to the Hugging Face Hub. It requires specifying the base model, the target Hugging Face repository name (`--upload-repo`), and the original model's path/repo name (`--hf-path`) for attribution.
SOURCE: https://github.com/ml-explore/mlx-lm/blob/main/mlx_lm/LORA.md#_snippet_7

LANGUAGE: shell
CODE:
```
mlx_lm.fuse \
    --model mistralai/Mistral-7B-v0.1 \
    --upload-repo mlx-community/my-lora-mistral-7b \
    --hf-path mistralai/Mistral-7B-v0.1
```

----------------------------------------

TITLE: Tools Data Format Example (Compact) - JSONL
DESCRIPTION: This JSONL example shows a compact representation of the 'tools' data format. Each line contains messages including a tool call by the assistant and a definition of the tools available, specified in a separate 'tools' array.
SOURCE: https://github.com/ml-explore/mlx-lm/blob/main/mlx_lm/LORA.md#_snippet_10

LANGUAGE: jsonl
CODE:
```
{"messages":[{"role":"user","content":"What is the weather in San Francisco?"},{"role":"assistant","tool_calls":[{"id":"call_id","type":"function","function":{"name":"get_current_weather","arguments":"{\"location\": \"San Francisco, USA\", \"format\": \"celsius\"}"}}]}],"tools":[{"type":"function","function":{"name":"get_current_weather","description":"Get the current weather","parameters":{"type":"object","properties":{"location":{"type":"string","description":"The city and country, eg. San Francisco, USA"},"format":{"type":"string","enum":["celsius","fahrenheit"]}},"required":["location","format"]}}}]}
```

----------------------------------------

TITLE: Example mlx-lm Model Merge Configuration (YAML)
DESCRIPTION: An example configuration file (`config.yaml`) for the `mlx_lm.merge` command. It specifies a list of models to merge (`models`), the merging `method` (currently only `slerp` is supported), and `parameters` for the chosen method, including layer-specific filters and value lists for interpolated merging.
SOURCE: https://github.com/ml-explore/mlx-lm/blob/main/mlx_lm/MERGE.md#_snippet_2

LANGUAGE: yaml
CODE:
```
models:
  - OpenPipe/mistral-ft-optimized-1218
  - mlabonne/NeuralHermes-2.5-Mistral-7B
method: slerp
parameters:
  t:
    - filter: self_attn
      value: [0, 0.5, 0.3, 0.7, 1]
    - filter: mlp
      value: [1, 0.5, 0.7, 0.3, 0]
    - value: 0.5
```

----------------------------------------

TITLE: Configuring - Single Hugging Face Dataset - YAML
DESCRIPTION: This YAML snippet demonstrates how to define a single Hugging Face dataset source for MLX LM. It specifies the dataset `path` and maps `prompt_feature` and `completion_feature` keys from the dataset to the features expected by the model. This config is typically saved to a file and passed to the MLX LM training script.
SOURCE: https://github.com/ml-explore/mlx-lm/blob/main/mlx_lm/LORA.md#_snippet_16

LANGUAGE: YAML
CODE:
```
hf_dataset:
  path: "billsum"
  prompt_feature: "text"
  completion_feature: "summary"
```

----------------------------------------

TITLE: Chat Data Format Example - JSONL
DESCRIPTION: This JSONL example shows the required format for 'chat' datasets used with `mlx_lm.lora`. Each line is a JSON object containing a list of messages, where each message has a role (system, user, assistant) and content.
SOURCE: https://github.com/ml-explore/mlx-lm/blob/main/mlx_lm/LORA.md#_snippet_9

LANGUAGE: jsonl
CODE:
```
{"messages": [{"role": "system", "content": "You are a helpful assistant."}, {"role": "user", "content": "Hello."}, {"role": "assistant", "content": "How can I assistant you today."}]}
```

----------------------------------------

TITLE: Initiating Model Fine-tuning with mlx_lm.lora - Shell
DESCRIPTION: This command starts the fine-tuning process using the `mlx_lm.lora` tool. It requires specifying the base model, enabling training mode, providing the path to the training data, and setting the number of training iterations. The data path should contain `train.jsonl` and `valid.jsonl`.
SOURCE: https://github.com/ml-explore/mlx-lm/blob/main/mlx_lm/LORA.md#_snippet_2

LANGUAGE: shell
CODE:
```
mlx_lm.lora \
    --model <path_to_model> \
    --train \
    --data <path_to_data> \
    --iters 600
```

----------------------------------------

TITLE: Fusing and Exporting Model to GGUF Format - Shell
DESCRIPTION: This command uses `mlx_lm.fuse` to merge adapters into the base model and then exports the fused model to the GGUF format. It requires specifying the base model and enabling the GGUF export flag. GGUF support is currently limited to certain model types and precision.
SOURCE: https://github.com/ml-explore/mlx-lm/blob/main/mlx_lm/LORA.md#_snippet_8

LANGUAGE: shell
CODE:
```
mlx_lm.fuse \
    --model mistralai/Mistral-7B-v0.1 \
    --export-gguf
```

----------------------------------------

TITLE: Evaluating Fine-tuned Model Perplexity with mlx_lm.lora - Shell
DESCRIPTION: This command uses the `mlx_lm.lora` tool to evaluate the perplexity of a fine-tuned model on a test dataset. It requires specifying the base model, the path to the saved adapters, the path to the data directory containing `test.jsonl`, and enabling the test mode.
SOURCE: https://github.com/ml-explore/mlx-lm/blob/main/mlx_lm/LORA.md#_snippet_3

LANGUAGE: shell
CODE:
```
mlx_lm.lora \
    --model <path_to_model> \
    --adapter-path <path_to_adapters> \
    --data <path_to_data> \
    --test
```

----------------------------------------

TITLE: Fusing Adapters into Base Model with mlx_lm.fuse - Shell
DESCRIPTION: This command executes the `mlx_lm.fuse` tool to merge the learned LoRA/QLoRA adapters into the base model specified by `--model`. By default, it loads adapters from `adapters/` and saves the fused model to `fused_model/`. Output location and adapter path are configurable.
SOURCE: https://github.com/ml-explore/mlx-lm/blob/main/mlx_lm/LORA.md#_snippet_6

LANGUAGE: shell
CODE:
```
mlx_lm.fuse --model <path_to_model>
```

----------------------------------------

TITLE: Completions Data Format Example - JSONL
DESCRIPTION: This JSONL example shows the required format for 'completions' datasets used with `mlx_lm.lora`. Each line is a JSON object with keys for the 'prompt' and the corresponding 'completion'. Alternate key names can be specified in a YAML config.
SOURCE: https://github.com/ml-explore/mlx-lm/blob/main/mlx_lm/LORA.md#_snippet_12

LANGUAGE: jsonl
CODE:
```
{"prompt": "What is the capital of France?", "completion": "Paris."}
```

----------------------------------------

TITLE: Running pre-commit Hooks on Specific Files (Shell)
DESCRIPTION: Executes the configured pre-commit hooks (like `black` and `clang-format`) only on the specified files. This is useful for checking formatting or other hooks on files you've modified. Requires `pre-commit` to be installed and `pre-commit install` to have been run in the repo.
SOURCE: https://github.com/ml-explore/mlx-lm/blob/main/CONTRIBUTING.md#_snippet_2

LANGUAGE: shell
CODE:
```
# single file
pre-commit run --files file1.py

# specific files
pre-commit run --files file1.py file2.py
```

----------------------------------------

TITLE: Running Project Tests with unittest (Shell)
DESCRIPTION: Discovers and runs all tests located within the `tests/` directory using Python's built-in `unittest` framework. This verifies that code changes or new model implementations pass existing tests. Requires the project to be installed and test dependencies met.
SOURCE: https://github.com/ml-explore/mlx-lm/blob/main/CONTRIBUTING.md#_snippet_4

LANGUAGE: shell
CODE:
```
python -m unittest discover tests/
```

----------------------------------------

TITLE: Generating Text with a Fine-tuned Model using mlx_lm.generate - Shell
DESCRIPTION: This command utilizes the `mlx_lm.generate` tool to perform text generation using a base model combined with a specified adapter. It requires providing the base model path, the path to the fine-tuned adapters, and the initial prompt for generation.
SOURCE: https://github.com/ml-explore/mlx-lm/blob/main/mlx_lm/LORA.md#_snippet_4

LANGUAGE: shell
CODE:
```
mlx_lm.generate \
    --model <path_to_model> \
    --adapter-path <path_to_adapters> \
    --prompt "<your_model_prompt>"
```

----------------------------------------

TITLE: Displaying mlx_lm.fuse Help Options - Shell
DESCRIPTION: This command displays the full list of available command-line options and arguments for the `mlx_lm.fuse` tool, which is used to merge LoRA/QLoRA adapters into the base model weights, and optionally upload or export the fused model.
SOURCE: https://github.com/ml-explore/mlx-lm/blob/main/mlx_lm/LORA.md#_snippet_5

LANGUAGE: shell
CODE:
```
mlx_lm.fuse --help
```

----------------------------------------

TITLE: YAML Configuration Example for Data Features
DESCRIPTION: This YAML snippet illustrates how to configure alternate key names for the prompt and completion fields in the 'completions' data format when using a configuration file with `mlx_lm.lora`. Default keys are 'prompt' and 'completion'.
SOURCE: https://github.com/ml-explore/mlx-lm/blob/main/mlx_lm/LORA.md#_snippet_14

LANGUAGE: yaml
CODE:
```
prompt_feature: "input"
completion_feature: "output"
```

----------------------------------------

TITLE: Making Chat Completion Request via Curl
DESCRIPTION: This `curl` command sends a POST request to the MLX LM server's chat completion endpoint at `/v1/chat/completions`. It includes a JSON payload specifying the conversation history (`messages`) and generation parameters like `temperature`.
SOURCE: https://github.com/ml-explore/mlx-lm/blob/main/mlx_lm/SERVER.md#_snippet_3

LANGUAGE: shell
CODE:
```
curl localhost:8080/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
     "messages": [{"role": "user", "content": "Say this is a test!"}],
     "temperature": 0.7
   }'
```

----------------------------------------

TITLE: Formatting C++ Code with clang-format (Shell)
DESCRIPTION: Formats a single C++ source file in-place using the `clang-format` tool. This ensures consistent coding style across the project. Requires `clang-format` to be installed and available in the system's PATH. The `-i` flag indicates in-place editing.
SOURCE: https://github.com/ml-explore/mlx-lm/blob/main/CONTRIBUTING.md#_snippet_0

LANGUAGE: shell
CODE:
```
clang-format -i file.cpp
```

----------------------------------------

TITLE: Text Data Format Example - JSONL
DESCRIPTION: This JSONL example shows the required format for 'text' datasets used with `mlx_lm.lora`. Each line is a JSON object containing a single key, typically 'text', with the raw text content for training or evaluation.
SOURCE: https://github.com/ml-explore/mlx-lm/blob/main/mlx_lm/LORA.md#_snippet_13

LANGUAGE: jsonl
CODE:
```
{"text": "This is an example for the model."}
```

----------------------------------------

TITLE: Running mlx_lm.lora with a YAML Config - Shell
DESCRIPTION: This command shows how to execute the `mlx_lm.lora` tool using options specified in a YAML configuration file. Command-line flags can be used simultaneously and will override corresponding values from the config file.
SOURCE: https://github.com/ml-explore/mlx-lm/blob/main/mlx_lm/LORA.md#_snippet_1

LANGUAGE: shell
CODE:
```
mlx_lm.lora --config /path/to/config.yaml
```

----------------------------------------

TITLE: Installing - Hugging Face Datasets Library - Shell
DESCRIPTION: This snippet shows the command to install the `datasets` Python package from PyPI. This package is a prerequisite for using Hugging Face datasets with MLX LM. It should be executed in a terminal or command prompt where Python is installed.
SOURCE: https://github.com/ml-explore/mlx-lm/blob/main/mlx_lm/LORA.md#_snippet_15

LANGUAGE: Shell
CODE:
```
pip install datasets
```

----------------------------------------

TITLE: Starting MLX LM HTTP Server with Hugging Face Model (Example)
DESCRIPTION: This command provides a concrete example of starting the MLX LM HTTP server using the `mlx-community/Mistral-7B-Instruct-v0.3-4bit` model from Hugging Face. The server will download the model if it's not available locally and start on port 8080.
SOURCE: https://github.com/ml-explore/mlx-lm/blob/main/mlx_lm/SERVER.md#_snippet_1

LANGUAGE: shell
CODE:
```
mlx_lm.server --model mlx-community/Mistral-7B-Instruct-v0.3-4bit
```

----------------------------------------

TITLE: Displaying mlx_lm.lora Help Options - Shell
DESCRIPTION: This command displays the full list of available command-line options and arguments for the `mlx_lm.lora` tool, which is used for LoRA/QLoRA fine-tuning, evaluation, and related tasks.
SOURCE: https://github.com/ml-explore/mlx-lm/blob/main/mlx_lm/LORA.md#_snippet_0

LANGUAGE: shell
CODE:
```
mlx_lm.lora --help
```

TITLE: Loading and Processing MNIST with MLX Data (Python)
DESCRIPTION: Demonstrates how to load the MNIST dataset using MLX Data's built-in loader and build a data processing pipeline. The pipeline shuffles the data, converts it to a stream, applies a key transformation to flatten and cast images, batches samples, and prefetches batches for efficiency. Finally, it shows how to iterate through the resulting batches.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/docs/src/quick_start.rst#_snippet_0

LANGUAGE: python
CODE:
```
# This is the standard way to import and access mlx.data
import mlx.data as dx

# Let's import MNIST loading
from mlx.data.datasets import load_mnist

# Loads a buffer with the MNIST images
mnist_train = load_mnist(train=True)

# Let's shuffle flatten and batch to prepare for MLP training
mnist_mlp = (
    mnist_train
    .shuffle()
    .to_stream()
    .key_transform("image", lambda x: x.astype("float32").reshape(-1))
    .batch(32)
    .prefetch(4, 2)
)

# Now we can iterate over the batches in normal python
for batch in mnist_mlp:
    x, y = batch["image"], batch["label"]

```

----------------------------------------

TITLE: Loading and Processing MNIST Dataset in MLX Data (Python)
DESCRIPTION: Demonstrates loading the MNIST dataset using `load_mnist` and setting up a basic data processing pipeline. The pipeline includes shuffling the data, converting it to a stream, transforming the image data (normalizing and flattening), batching samples, and prefetching for performance.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/docs/src/python/common_datasets.rst#_snippet_0

LANGUAGE: python
CODE:
```
import mlx.data as dx
from mlx.data.datasets import load_mnist, load_wikitext_lines
from mlx.data.tokenizer_helpers import read_trie_from_vocab

mnist = load_mnist()
print(mnist)
# Downloading http://yann.lecun.net/exdb/mnist/train-images-idx3-ubyte.gz 9.5MiB (15.1MiB/s)
# Downloading http://yann.lecun.net/exdb/mnist/t10k-images-idx3-ubyte.gz 1.6MiB (12.9MiB/s)
# Downloading http://yann.lecun.net/exdb/mnist/train-labels-idx1-ubyte.gz 32.0KiB (17.1MiB/s)
# Downloading http://yann.lecun.net/exdb/mnist/t10k-labels-idx1-ubyte.gz 8.0KiB (26.6MiB/s)
# Buffer(size=60000, keys={'label', 'image'})

mnist_iter = (
    mnist
    .shuffle()
    .to_stream()
    .key_transform("image", lambda x: (x.astype("float32") / 255).ravel())
    .batch(128)
    .prefetch(4, 2)
)
print(next(mnist_iter)["image"].shape)
# (128, 784)
```

----------------------------------------

TITLE: Loading and Tokenizing Wikitext-103 Dataset in MLX Data (Python)
DESCRIPTION: Shows how to load the wikitext-103 dataset, read a tokenizer trie from a vocabulary file, and build a complex data pipeline for natural language processing. The pipeline includes tokenization, filtering, prefetching, two stages of batching (one to gather tokens into an array, another for the final sample size), sliding window, and reshaping.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/docs/src/python/common_datasets.rst#_snippet_1

LANGUAGE: python
CODE:
```
wiki = load_wikitext_lines(split="train")
print(wiki)
# Downloading https://s3.amazonaws.com/research.metamind.io/wikitext/wikitext-103-raw-v1.zip 183.1MiB (9.9MiB/s)
# Computing hash of ..../.cache/mlx.data/wikitext/wikitext-103-raw-v1.zip |████████████████████████████████████████| 183.1MiB / 183.1MiB (1.0GiB/s)
# Extracting ..../.cache/mlx.data/wikitext/wikitext-103-raw-v1.zip 517.9MiB (318.2MiB/s)
# Stream()

workers = 8
trie = read_trie_from_vocab("/path/to/vocab.txt")
wiki_iterator = (
    wiki
    .tokenize("line", trie, output_key="tokens")
    .filter_key("tokens")
    .prefetch(512, workers)
    .batch(128, dim=dict(tokens=0))  # gather everything in a big array of tokens
    .sliding_window("tokens", 1025, 1025)
    .shape("tokens", "tokens_length", 0)
    .batch(32)  # actual batch size
    .prefetch(2, 1)
)
# The above can be iterated at approximately 2.5M tok/s on an M2 Macbook Air.
```

----------------------------------------

TITLE: Example Usage of MLX Streams for Training Epoch
DESCRIPTION: Demonstrates how to use the `hf_dataset_to_mlx_stream` function to create MLX streams for training and testing dataset splits. It resets the training stream, iterates through the first batch, converts the batch data to MLX arrays, prints the label of the first image, and displays the image using matplotlib for visualization.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/docs/src/hf_datasets_streams.rst#_snippet_11

LANGUAGE: python
CODE:
```
import matplotlib.pyplot as plt
import mlx.core as mx

train_stream = hf_dataset_to_mlx_stream(ds['train'], shuffle=True)
test_stream = hf_dataset_to_mlx_stream(ds['test'], shuffle=False)

train_stream.reset()
for batch in train_stream:
    (X, y) = mx.array(batch['image']), mx.array(batch['label'])

    print('The image should display a ', y[0].item())
    plt.imshow(X[0])
    break
```

----------------------------------------

TITLE: Helper Functions for Hugging Face to MLX Stream Conversion
DESCRIPTION: Provides two functions: `huggingface_to_array_of_dict` (same as previous definition) for converting dataset rows to NumPy dicts, and `hf_dataset_to_mlx_stream` which wraps the conversion to buffer and stream creation, including optional shuffling and common stream operations like normalization, batching, and prefetching.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/docs/src/hf_datasets_streams.rst#_snippet_10

LANGUAGE: python
CODE:
```
import numpy as np
import mlx.data as dx

# Convert the content of the dataset into numpy arrays
def huggingface_to_array_of_dict(dataset):
    return [{"image": np.array(image).copy(), "label": label}
            for label, image in zip(dataset['label'], dataset['image'])]

# Convert the Hugging Face dataset to a stream of batches
def hf_dataset_to_mlx_stream(dataset, shuffle=False):
    numpy_data = huggingface_to_array_of_dict(dataset)

    buffer = dx.buffer_from_vector(numpy_data)
    if shuffle:
        buffer = buffer.shuffle()

    return (
        buffer
        .to_stream()
        .key_transform("image", lambda x: x.astype("float32") / 255)
        .batch(32)
        .prefetch(prefetch_size=8, num_threads=4)
    )
```

----------------------------------------

TITLE: Using and Transforming Stream in MLX Data Python
DESCRIPTION: This snippet demonstrates how to create a large stream from a Python iterable using `dx.stream_python_iterable`, apply transformations like filtering using `sample_transform`, and access elements sequentially with `next()`. It also shows that streams are mutable stateful objects, and resetting a stream allows re-iteration from the beginning. Requires the `mlx.data` library.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/docs/src/python/stream.rst#_snippet_0

LANGUAGE: python
CODE:
```
import mlx.data as dx

# The samples are never all instantiated
numbers = dx.stream_python_iterable(lambda: ({"x": i} for i in range(10**10)))

# Filtering is done with transforms returning an empty sample
evens = numbers.sample_transform(lambda s: s if s["x"] % 2 == 0 else dict())

print(next(numbers))
# prints {'x': array(0)}
print(next(numbers))
# prints {'x': array(1)}

# Streams are pointers to the streams so evens is using numbers under the
# hood. Since numbers was advanced now evens is advanced as well.
print(next(evens))
# prints {'x': array(2)}
print(next(evens))
# prints {'x': array(4)}
print(next(numbers))
# prints {'x': array(5)}

# Streams can be reset.
evens.reset()
print(next(evens))
print(next(evens))
print(next(numbers))
# prints {'x': array(0)}
#        {'x': array(2)}
#        {'x': array(3)}
```

----------------------------------------

TITLE: Building MLX Data Pipeline - Python
DESCRIPTION: This snippet demonstrates how to create a data loading and preprocessing pipeline using the MLX Data library in Python. It starts with a helper function `files_and_classes` to generate a list of sample dictionaries containing file paths and labels. This list is then used to create a MLX Data buffer, which is subsequently transformed into a shuffled stream. The stream is processed through image operations (loading, resizing, cropping), batched, and key-transformed to normalize image data before being prefetched for efficient iteration.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/README.md#_snippet_0

LANGUAGE: Python
CODE:
```
# A simple python function returning a list of dicts. All samples in MLX data
# are dicts of arrays.
def files_and_classes(root: Path):
    files = [str(f) for f in root.glob("**/*.jpg")]
    files = [f for f in files if "BACKGROUND" not in f]
    classes = dict(
        map(reversed, enumerate(sorted(set(f.split("/")[-2] for f in files))))
    )

    return [
        dict(image=f.encode("ascii"), label=classes[f.split("/")[-2]]) for f in files
    ]

dset = (
    # Make a buffer (finite length container of samples) from the python list
    dx.buffer_from_vector(files_and_classes(root))

    # Shuffle and transform to a stream
    .shuffle()
    .to_stream()

    # Implement a simple image pipeline. No random augmentations here but they
    # could be applied.
    .load_image("image")  # load the file pointed to by the 'image' key as an image
    .image_resize_smallest_side("image", 256)
    .image_center_crop("image", 224, 224)

    # Accumulate into batches
    .batch(batch_size)

    # Cast to float32 and scale to [0, 1]. We do this in python and we could
    # have done any transformation we could think of.
    .key_transform("image", lambda x: x.astype("float32") / 255)

    # Finally, fetch batches in background threads
    .prefetch(prefetch_size=8, num_threads=8)
)

# dset is a python iterable so one could simply
for sample in dset:
    # access sample["image"] and sample["label"]
    pass
```

----------------------------------------

TITLE: Creating and Accessing mlx.data Buffer in Python
DESCRIPTION: This snippet demonstrates how to create an mlx.data Buffer from a Python list of dictionaries, apply a key transformation to modify sample values, and then access basic properties like printing the buffer representation, accessing a specific element by index, and getting the buffer's size.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/docs/src/python/buffer.rst#_snippet_0

LANGUAGE: python
CODE:
```
import mlx.data as dx

numbers = dx.buffer_from_vector([{"x": i} for i in range(10)])
evens = numbers.key_transform("x", lambda x: 2*x)

print(evens)
# prints Buffer(size=10, keys={'x'})

print(evens[3])
# prints {'x': array(6)}

print(len(evens))
# prints 10
```

----------------------------------------

TITLE: Installing MLX Data with pip (Bash)
DESCRIPTION: Installs the MLX Data package from the Python Package Index (PyPI). This command fetches the pre-built package, including necessary dependencies for reading various file types and S3 content on compatible systems (Linux, Apple silicon Macs).
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/docs/src/install.rst#_snippet_0

LANGUAGE: Bash
CODE:
```
pip install mlx-data
```

----------------------------------------

TITLE: Installing Hugging Face Datasets
DESCRIPTION: This command uses pip, the Python package installer, to install the `datasets` library from the Python Package Index (PyPI). This is a prerequisite for downloading and loading datasets from the Hugging Face Hub.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/docs/src/hf_datasets_streams.rst#_snippet_0

LANGUAGE: bash
CODE:
```
pip install datasets
```

----------------------------------------

TITLE: Creating Buffer from List - MLX Data - Python
DESCRIPTION: Demonstrates creating an MLX Buffer from a Python list of samples generated by a helper function. It uses `dx.buffer_from_vector` with the output of a function that processes image files and their categories, showing how to structure samples for a dataset.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/docs/src/buffers_streams_samples.rst#_snippet_1

LANGUAGE: python
CODE:
```
from pathlib import Path

import mlx.data as dx

def files_and_classes(root: Path):
    """Load the files and classes from an image dataset that contains one folder per class."""
    images = list(root.rglob("*.jpg"))
    categories = [p.relative_to(root).parent.name for p in images]
    category_set = set(categories)
    category_map = {c: i for i, c in enumerate(sorted(category_set))}

    return [
        {
            "image": str(p.relative_to(root)).encode("ascii"),
            "category": c,
            "label": category_map[c]
        }
        for c, p in zip(categories, images)
    ]

dset = dx.buffer_from_vector(files_and_classes(Path("path/to/dataset)))
# We can now apply transformations to the dataset
```

----------------------------------------

TITLE: Processing Buffer as Stream with Prefetch - MLX Data - Python
DESCRIPTION: Shows how to transform an MLX Buffer into a Stream using `.to_stream()` to enable stream-specific operations like batching and non-deterministic prefetching. It demonstrates chaining operations: shuffle, convert to stream, batch, and prefetch for efficient iteration.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/docs/src/buffers_streams_samples.rst#_snippet_2

LANGUAGE: python
CODE:
```
# We can define the rest of the processing pipeline using streams.
# 1. First shuffle the buffer
# 2. Make a stream
# 3. Batch and then prefetch
dset = (
    dset
    .shuffle()
    .to_stream()  # <-- making a stream from the shuffled buffer
    .batch(32)
    .prefetch(8, 4)  # <-- prefetch 8 batches using 4 threads
)

# Now we can iterate over dset
sample = next(dset)
```

----------------------------------------

TITLE: Creating an MLX Buffer from a List of Dictionaries
DESCRIPTION: Imports the MLX data library as `dx`. It then uses the `dx.buffer_from_vector()` function to convert a Python list of dictionaries, where values are typically NumPy arrays or other standard types, into an MLX Buffer object. This Buffer is the intermediate representation before creating a Stream.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/docs/src/hf_datasets_streams.rst#_snippet_7

LANGUAGE: python
CODE:
```
import mlx.data as dx

buffer = dx.buffer_from_vector(dicts)
```

----------------------------------------

TITLE: Creating an MLX Stream with Transformations and Batching
DESCRIPTION: Converts the MLX Buffer into an MLX Stream using `.to_stream()`. It chains several operations: `key_transform` normalizes the 'image' data to float32 in the range [0, 1], `batch` groups samples into batches of size 32, and `prefetch` enables background loading of batches with 8 batches preloaded using 4 threads.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/docs/src/hf_datasets_streams.rst#_snippet_8

LANGUAGE: python
CODE:
```
stream = buffer
    .to_stream()
    .key_transform("image", lambda x: x.astype("float32") / 255)
    .batch(32)
    .prefetch(prefetch_size=8, num_threads=4)
```

----------------------------------------

TITLE: Loading a Dataset from Hugging Face
DESCRIPTION: Imports the `load_dataset` function from the Hugging Face `datasets` library and uses it to download and load the 'ylecun/mnist' dataset. It then prints the loaded dataset object, specifically focusing on the 'train' split to show its structure.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/docs/src/hf_datasets_streams.rst#_snippet_1

LANGUAGE: python
CODE:
```
from datasets import load_dataset

ds = load_dataset("ylecun/mnist")
print(ds['train'])
```

----------------------------------------

TITLE: Defining MLX Samples - MLX Data - Python
DESCRIPTION: Shows various ways to define a sample dictionary in MLX data. Samples are dictionaries mapping string keys to values that are cast to MLX arrays, including numpy arrays, scalars, and strings (bytes recommended for paths or raw data).
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/docs/src/buffers_streams_samples.rst#_snippet_0

LANGUAGE: python
CODE:
```
# This is a valid sample
sample = {"hello": np.array(0)}

# So is this because scalars are cast to scalar arrays
sample = {"scalar": 42}

# Strings can also be used, however, they will be represented in unicode.
sample = {"key": "value"}

# Most likely you would want to write it as bytes in the sample as follows
sample = {"key": b"path/to/my/file"}
sample = {"key": "value".encode("ascii")}
```

----------------------------------------

TITLE: Initialize and Use AWSFileFetcher Python
DESCRIPTION: This snippet demonstrates how to initialize the `AWSFileFetcher` class with bucket details, an optional endpoint, a local cache directory, and cache size. It shows examples of fetching a single file synchronously using `fetch` and initiating background downloads for multiple files using `prefetch`.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/docs/src/python/miscellaneous.rst#_snippet_0

LANGUAGE: python
CODE:
```
from pathlib import Path
from mlx.data.core import AWSFileFetcher

LOCAL_CACHE = Path("/path/to/local/cache")

ff = AWSFileFetcher(
    "my-cool-bucket",
    endpoint="https://my.endpoint.com/"
    local_prefix=LOCAL_CACHE,
    num_kept_files=100,
)

# When fetch returns my/remote/path/foo.npy will be in LOCAL_CACHE
ff.fetch("my/remote/path/foo.npy")
assert (LOCAL_CACHE / "my/remote/path/foo.npy").is_file()

# We can prefetch in the background
ff.prefetch(["foo_1.npy", "foo_2.npy"])
ff.fetch("foo_1.npy")
# process foo_1 while foo_2 downloads in the background
```

----------------------------------------

TITLE: Applying Python Transforms in MLX Data (Python)
DESCRIPTION: Illustrates examples of using Python functions within MLX Data pipelines for custom transformations and filtering. This includes normalizing image data using `key_transform` with a lambda function, applying an audio feature extraction function (`mfsc`), and filtering samples based on a condition using `sample_transform`.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/docs/src/quick_start.rst#_snippet_1

LANGUAGE: python
CODE:
```
# Normalizing images in [0, 1]
dset = dset.key_transform("image", lambda x: x.astype("float32") / 255)

# Extracting mel spectrogram features
# A big chunk of the time is spent computing the FFT which is done with the GIL off so...
from mlx.data.features import mfsc
dset = dset.key_transform("audio", mfsc(n_filterbank=80, sampling_freq=16000))

# Filter stream samples based on values (empty dict means drop the sample)
dset = dset.sample_transform(lambda s: s if s["length"] > 10 else dict())

```

----------------------------------------

TITLE: Building MLX Data Python Bindings (pip/Bash)
DESCRIPTION: Navigates to the MLX Data source directory and uses pip to build and install the Python library along with its required C++ backend. The `-e .` option is mentioned as an alternative for an editable install suitable for development.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/docs/src/install.rst#_snippet_5

LANGUAGE: Bash
CODE:
```
cd /path/to/mlx/data
pip install .  # or pip install -e . for an editable install
```

----------------------------------------

TITLE: Loading CharTrie from SPM File & Tokenizing (Python)
DESCRIPTION: This snippet illustrates how to load a `CharTrie` and corresponding token weights from a SentencePiece model file using the `read_trie_from_spm` helper. It then creates a `Tokenizer` using the loaded trie and weights, demonstrating how to prepare a tokenizer based on a pre-trained model for efficient tokenization.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/docs/src/python/tokenizing.rst#_snippet_2

LANGUAGE: python
CODE:
```
from mlx.data.tokenizer_helpers import read_trie_from_spm

trie, weights = read_trie_from_spm("path/to/spm/model")
tokenizer = Tokenizer(trie, trie_key_scores=weights)
tokenizer.tokenize_shortest(b"This is some more text to tokenize")
```

----------------------------------------

TITLE: Using key_transform in MLX Stream
DESCRIPTION: Highlights the `.key_transform("image", ...)` operation within an MLX Stream pipeline. This function applies a specified lambda function (or any callable) to the data associated with the key 'image' for each sample processed by the stream. It's used here for preprocessing like normalization or reshaping.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/docs/src/hf_datasets_streams.rst#_snippet_9

LANGUAGE: python
CODE:
```
.key_transform("image", ...)
```

----------------------------------------

TITLE: Installing MLX Data Dependencies (apt/Ubuntu)
DESCRIPTION: Installs core optional system dependencies required for specific MLX Data functionalities (audio, video, images, compression) on Ubuntu using the apt package manager. This command covers libraries for sound, video, images, and compression.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/docs/src/install.rst#_snippet_2

LANGUAGE: Bash
CODE:
```
sudo apt install libsndfile1-dev libsamplerate0-dev ffmpeg libjpeg-turbo8-dev \
    zlib1g-dev libbz2-dev liblzma-dev
```

----------------------------------------

TITLE: Applying Conditional Transformations with mlx.data Python
DESCRIPTION: This Python snippet demonstrates how to chain conditional transformation methods (`*_if`) on an mlx.data buffer (`dset`). It applies transformations like image loading, conditional random cropping, conditional horizontal flipping, and conditional key transformation (brightness adjustment) based on boolean flags or probabilities, allowing for pipeline configuration without redirection.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/docs/src/python/dataset.rst#_snippet_0

LANGUAGE: python
CODE:
```
# Assuming we have a buffer with image files and labels in dset
dset = (
    dset
    .load_image("image_file", output_key="image")
    .image_random_crop_if(enable_random_crop, "image", 256, 256)
    .image_random_h_flip_if(flip_prob > 0, "image", flip_prob)
    .key_transform_if(brightness_range > 0, "image",
                      lambda x: ((1 + brightness_range * np.random.rand(x.shape[:2])[..., None]) * x).astype(x.dtype))
)
```

----------------------------------------

TITLE: Adding Characters to CharTrie & Tokenizing (Python)
DESCRIPTION: This demonstrates adding individual lowercase and uppercase ASCII letters as single-character tokens to an existing `CharTrie`. It then tokenizes a new byte string using the same `Tokenizer`, showing how the extended vocabulary in the trie influences the resulting token sequence.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/docs/src/python/tokenizing.rst#_snippet_1

LANGUAGE: python
CODE:
```
import string
for l in string.ascii_letters:
    trie.insert(bytes(l, "utf-8"))

print(tokenizer.tokenize_shortest(b"This is a quick example"))
```

----------------------------------------

TITLE: Converting Hugging Face Dataset to List of Dicts with NumPy Arrays
DESCRIPTION: Defines a Python function `huggingface_to_array_of_dict` that iterates through a Hugging Face dataset split. For each sample, it converts the image (assumed to be a PIL Image) to a NumPy array using `np.array()` and creates a dictionary containing the 'image' array and the 'label'. It returns a list of these dictionaries, suitable for MLX Buffer creation.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/docs/src/hf_datasets_streams.rst#_snippet_5

LANGUAGE: python
CODE:
```
import numpy as np

def huggingface_to_array_of_dict(dataset):
    return [{"image": np.array(image).copy(), "label": label}
            for label, image in zip(dataset['label'], dataset['image'])]
```

----------------------------------------

TITLE: Building & Using CharTrie Manually (Python)
DESCRIPTION: This snippet shows how to initialize a `CharTrie` and insert byte sequences (tokens) into it. It then demonstrates creating a `Tokenizer` with this trie and using the `tokenize_shortest` method to tokenize an input byte string, outputting a list of corresponding integer indices.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/docs/src/python/tokenizing.rst#_snippet_0

LANGUAGE: python
CODE:
```
from mlx.data.core import CharTrie, Tokenizer

# We can build a trie ourselves
trie = CharTrie()
for t in b"a quick brown fox jumped over the lazy dog".split():
    trie.insert(t)
trie.insert(b" ")

tokenizer = Tokenizer(trie)
print(tokenizer.tokenize_shortest(b"a quick brown fox jumped over the lazy dog"))
```

----------------------------------------

TITLE: Processing Buffer with Ordered Prefetch - MLX Data - Python
DESCRIPTION: Demonstrates applying batching and deterministic prefetching directly to an MLX Buffer using `.ordered_prefetch()`. This method implicitly converts the buffer to a stream while ensuring a specific processing order, suitable when deterministic iteration is required.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/docs/src/buffers_streams_samples.rst#_snippet_3

LANGUAGE: python
CODE:
```
# We can define the rest of the processing pipeline using streams.
# 1. First shuffle the buffer
# 2. Make a stream
# 3. Batch and then prefetch
dset = (
    dset
    .shuffle()
    .batch(32)
    .ordered_prefetch(8, 4)  # <-- prefetch 8 batches in a stream using 4 threads
)

# Now we can iterate over dset
sample = next(dset)
```

----------------------------------------

TITLE: Converting Dataset and Verifying Output Structure
DESCRIPTION: Calls the `huggingface_to_array_of_dict` function to convert a dataset split (represented by the variable `dataset`) into the desired list of dictionaries. Includes `assert` statements to programmatically verify that the output `dicts` is indeed a list, contains dictionaries, and that the 'image' key in the first dictionary holds a NumPy array.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/docs/src/hf_datasets_streams.rst#_snippet_6

LANGUAGE: python
CODE:
```
dicts = huggingface_to_array_of_dict(dataset)

assert type(dicts) == list
assert type(dicts[0]) == dict
assert type(dicts[0]['image']) == np.ndarray
```

----------------------------------------

TITLE: Installing MLX Data Dependencies (Homebrew/macOS)
DESCRIPTION: Installs optional system dependencies required for specific MLX Data functionalities (audio, video, images, compression, S3 access) on macOS using the Homebrew package manager. Without these, corresponding features might not be built or available.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/docs/src/install.rst#_snippet_1

LANGUAGE: Bash
CODE:
```
brew install libsndfile libsamplerate ffmpeg jpeg-turbo zlib bzip2 xz aws-sdk-cpp
```

----------------------------------------

TITLE: Installing MLX Data Build Tools (pip/Bash)
DESCRIPTION: Installs the necessary Python packages, pybind11 (for creating Python bindings to C++ code) and CMake (a build system generator), using pip. These tools are prerequisites for building the MLX Data Python library from source.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/docs/src/install.rst#_snippet_4

LANGUAGE: Bash
CODE:
```
pip install pybind11[global] cmake
```

----------------------------------------

TITLE: Configuring Pybind11 Module Target in CMake
DESCRIPTION: This snippet defines a CMake target named `_c` using `pybind11_add_module`, listing the necessary C++ source files for the Python bindings. It then configures the target by adding include directories, linking it against the required `mlxdata` library, defining a compiler preprocessor macro for the version, and specifying the installation path within the `mlx/data` directory.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/python/src/CMakeLists.txt#_snippet_0

LANGUAGE: CMake
CODE:
```
pybind11_add_module(
  _c
  ${CMAKE_CURRENT_LIST_DIR}/wrap.cpp
  ${CMAKE_CURRENT_LIST_DIR}/wrap_buffer.cpp
  ${CMAKE_CURRENT_LIST_DIR}/wrap_core.cpp
  ${CMAKE_CURRENT_LIST_DIR}/wrap_stream.cpp)

target_include_directories(_c PUBLIC ${CMAKE_SOURCE_DIR})
target_link_libraries(_c PRIVATE mlxdata)
target_compile_definitions(_c PRIVATE _VERSION_=${MLX_DATA_VERSION})

install(TARGETS _c DESTINATION mlx/data)
```

----------------------------------------

TITLE: Fetching and Configuring pybind11
DESCRIPTION: This block is conditional on the `MLX_BUILD_PYTHON_BINDINGS` option. If enabled, it finds the Python interpreter and development libraries. It defines a patch command for pybind11, declares and fetches pybind11 from GitHub, applies the patch, and adds the fetched pybind11 source directory as a subdirectory to integrate its build system.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/CMakeLists.txt#_snippet_8

LANGUAGE: CMake
CODE:
```
if(MLX_BUILD_PYTHON_BINDINGS)
  find_package(Python COMPONENTS Interpreter Development.Module)

  # avoid warning regarding FindPythonInterp and FindPythonLibs modules which
  # are deprecated from CMake 3.27
  set(pybind11_patch git apply
                     ${CMAKE_CURRENT_SOURCE_DIR}/cmake/pybind11-v2.11.1.patch)
  FetchContent_Declare(
    pybind11
    GIT_REPOSITORY https://github.com/pybind/pybind11
    GIT_TAG v2.11.1
    # patch is always applied, so we silently fail if already patched
    PATCH_COMMAND ${pybind11_patch} || true)

  FetchContent_GetProperties(pybind11)
  if(NOT pybind11_POPULATED)
    FetchContent_Populate(pybind11)
    add_subdirectory(${pybind11_SOURCE_DIR} ${pybind11_BINARY_DIR})
  endif()
endif()
```

----------------------------------------

TITLE: Checking Image Data Type in Dataset
DESCRIPTION: This Python code snippet accesses the 'train' split of the loaded dataset and attempts to print the type of the elements within the 'image' column. This is done to inspect the initial format of the image data, which is often a library-specific object like a PIL Image.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/docs/src/hf_datasets_streams.rst#_snippet_3

LANGUAGE: python
CODE:
```
print(type(ds['train']['image']))
```

----------------------------------------

TITLE: Building Standalone MLX Data C++ Library (CMake/Bash)
DESCRIPTION: Provides shell commands to create a build directory, configure the C++ project using CMake, compile the library using Make, and install the resulting static library and headers into the system's default locations. This allows using MLX Data as a dependency in other C++ projects.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/docs/src/install.rst#_snippet_6

LANGUAGE: Bash
CODE:
```
mkdir build && cd build
cmake ..
make -j
sudo make install
```

----------------------------------------

TITLE: Running MLX Data WikiText Benchmark (bash)
DESCRIPTION: This command executes the main `mlx_data.py` script with specific parameters via bash. It sets the `OMP_NUM_THREADS` environment variable to 1 and passes the path to the SentencePiece tokenizer model and the directory containing the extracted WikiText103 dataset. This runs the MLX data processing benchmark.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/benchmarks/comparative/wikitext/README.md#_snippet_1

LANGUAGE: bash
CODE:
```
OMP_NUM_THREADS=1 python mlx_data.py \
    --tokenizer_file /path/to/tokenizer.model \
    /path/to/wikitext/wikitext-103-raw
```

----------------------------------------

TITLE: Running LibriSpeech Benchmark Script (Bash)
DESCRIPTION: Executes the provided bash script `run_librispeech.sh` to automate the data download, tokenizer setup, and benchmark execution process for the LibriSpeech dataset. This script simplifies the setup and running procedure. Requires `wget` and `unzip` dependencies if data needs downloading.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/benchmarks/comparative/librispeech/README.md#_snippet_0

LANGUAGE: bash
CODE:
```
bash run_librispeech.sh
```

----------------------------------------

TITLE: Run Caltech 101 Benchmark Script - Bash
DESCRIPTION: Executes the `run_caltech.sh` Bash script. This script is designed to automate the process of downloading the Caltech 101 dataset, extracting it, and then running the benchmark tests sequentially using the extracted data. Requires `wget` and `unzip` dependencies to handle data download and extraction.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/benchmarks/comparative/caltech101/README.md#_snippet_0

LANGUAGE: bash
CODE:
```
bash run_caltech.sh
```

----------------------------------------

TITLE: Building and Installing AWS SDK for S3 (Bash/Ubuntu)
DESCRIPTION: Provides a sequence of shell commands to build and install the AWS SDK for C++ from source on Ubuntu, specifically configured to include only the S3 component as a static library. This manual step is required for S3 access support when building MLX Data from source on Ubuntu if pre-built binaries are not used.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/docs/src/install.rst#_snippet_3

LANGUAGE: Bash
CODE:
```
sudo apt install libcurl4-openssl-dev libssl-dev
git clone --depth 1 --recurse-submodules https://github.com/aws/aws-sdk-cpp.git
cd aws-sdk-cpp
mkdir build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release -DBUILD_ONLY="s3" -DBUILD_SHARED_LIBS=OFF
make -j
sudo make install
```

----------------------------------------

TITLE: Formatting C++ File with clang-format (Shell)
DESCRIPTION: Demonstrates how to format a specific C++ source file (`file.cpp`) in-place using the `clang-format` command-line tool. The `-i` flag indicates in-place editing. This ensures consistent C++ code style and requires `clang-format` to be installed.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/CONTRIBUTING.md#_snippet_0

LANGUAGE: Shell
CODE:
```
clang-format -i file.cpp
```

----------------------------------------

TITLE: Add curl External Project
DESCRIPTION: Adds curl as an external project with dependencies on openssl and pkg-config. It's downloaded, configured with position-independent code flags and installation prefix, built, and installed. Shared libraries and LDAP support are disabled, enabling SSL support via the built openssl.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/super/CMakeLists.txt#_snippet_22

LANGUAGE: CMake
CODE:
```
ExternalProject_Add(
  curl
  URL https://curl.se/download/curl-8.5.0.tar.bz2
  DEPENDS openssl pkg-config
  CONFIGURE_COMMAND
    PATH=${PATH} PKG_CONFIG_PATH=${PKG_CONFIG_PATH} CFLAGS=-fPIC ./configure
    --disable-shared --with-openssl --disable-ldap
    --prefix=${CMAKE_BINARY_DIR}/deps
  BUILD_COMMAND make
  INSTALL_COMMAND make install
  BUILD_IN_SOURCE 1
  DOWNLOAD_EXTRACT_TIMESTAMP 1)
```

----------------------------------------

TITLE: Add openssl External Project
DESCRIPTION: Adds openssl as an external project. It's downloaded, configured with position-independent code flags and installation prefix, built, and installed. Shared libraries, specific ciphers (idea, mdc2, rc5), and tests are disabled.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/super/CMakeLists.txt#_snippet_21

LANGUAGE: CMake
CODE:
```
ExternalProject_Add(
  openssl
  URL https://www.openssl.org/source/openssl-1.1.1q.tar.gz
  CONFIGURE_COMMAND
    PATH=${PATH} PKG_CONFIG_PATH=${PKG_CONFIG_PATH} CFLAGS=-fPIC ./config
    no-shared no-idea no-mdc2 no-rc5 no-tests --prefix=${CMAKE_BINARY_DIR}/deps
  BUILD_COMMAND make depend && make
  INSTALL_COMMAND make install_sw
  BUILD_IN_SOURCE 1
  DOWNLOAD_EXTRACT_TIMESTAMP 1)
```

----------------------------------------

TITLE: Add AWS S3 SDK External Project
DESCRIPTION: Adds the AWS SDK for C++ (specifically the S3 component) as an external project with dependencies on openssl, curl, and pkg-config. It's cloned from Git, patched, and configured using CMake with options for release build, static library, PIC, and disabling testing, installing to a custom prefix.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/super/CMakeLists.txt#_snippet_23

LANGUAGE: CMake
CODE:
```
ExternalProject_Add(
  aws-s3
  GIT_REPOSITORY https://github.com/aws/aws-sdk-cpp.git
  GIT_TAG 1.11.231
  GIT_SHALLOW 1
  PATCH_COMMAND patch -p1 < ${CMAKE_SOURCE_DIR}/cmake/aws-1.11.231.patch
  DEPENDS openssl curl pkg-config
  CMAKE_ARGS -DCMAKE_BUILD_TYPE=Release
             -DBUILD_ONLY=s3
             -DBUILD_SHARED_LIBS=OFF
             -DBUILD_TESTING=OFF
             -DAUTORUN_UNIT_TESTS=OFF
             -DENABLE_TESTING=OFF
             -DCMAKE_POSITION_INDEPENDENT_CODE=ON
             -DCMAKE_PREFIX_PATH=${CMAKE_BINARY_DIR}/deps
             -DCMAKE_INSTALL_PREFIX=${CMAKE_BINARY_DIR}/deps
  INSTALL_DIR ${CMAKE_BINARY_DIR}/deps
  DOWNLOAD_EXTRACT_TIMESTAMP 1)
```

----------------------------------------

TITLE: Fetching and Configuring BXZSTR Library
DESCRIPTION: Defines a command to apply a patch file to the bxzstr source. `FetchContent_Declare` is used to download bxzstr from GitHub via Git tag, applying the defined patch. It populates the content if needed, configures the `config.hpp` file using `configure_file` based on found dependencies, and adds the source directory to the interface include directories.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/CMakeLists.txt#_snippet_7

LANGUAGE: CMake
CODE:
```
set(bxzstr_patch git apply ${CMAKE_CURRENT_SOURCE_DIR}/cmake/bxzstr.patch)
FetchContent_Declare(
  bxzstr
  GIT_REPOSITORY "https://github.com/tmaklin/bxzstr.git"
  GIT_TAG "a6e5d743b5547a3ec23fd842813dec8067c8aff1"
  # patch is always applied, so we silently fail if already patched
  PATCH_COMMAND ${bxzstr_patch} || true CONFIGURE_COMMAND "" BUILD_COMMAND "")
FetchContent_GetProperties(bxzstr)
if(NOT bxzstr_POPULATED)
  FetchContent_Populate(bxzstr)
  configure_file(${bxzstr_SOURCE_DIR}/bxzstr/config.hpp.in
                 ${bxzstr_SOURCE_DIR}/bxzstr/config.hpp)
endif()
target_include_directories(bxzstr INTERFACE ${bxzstr_SOURCE_DIR})
```

----------------------------------------

TITLE: Build MLX Data Project (CMake)
DESCRIPTION: Adds the main mlx-data project as an external build target using ExternalProject_Add. It doesn't download but uses CMake commands to remove a directory and create a symlink to the source. It depends on previously built libraries and passes several CMake arguments to configure the sub-build, including paths, build type, and linker flags determined earlier.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/super/CMakeLists.txt#_snippet_27

LANGUAGE: CMake
CODE:
```
# CMake does not like when source dir depends on targets which are in a
# subdirectory of the top source dir. We thus make a symlink in the build dir to
# avoid any error message (CMake also create the directory mlx-data beforehand,
# expecting it to be populated -- we remove this directory first in that
# respect)
ExternalProject_Add(
  mlx-data
  DOWNLOAD_COMMAND
    ${CMAKE_COMMAND} -E remove_directory mlx-data && ${CMAKE_COMMAND} -E
    create_symlink ${CMAKE_SOURCE_DIR}/.. mlx-data
  UPDATE_COMMAND ""
  DEPENDS zlib
          bzip2
          xz
          libsndfile
          libsamplerate
          libjpeg-turbo
          ffmpeg
          aws-s3
  CMAKE_ARGS -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
             -DCMAKE_PREFIX_PATH=${CMAKE_BINARY_DIR}/deps
             -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}
             -DMLX_BUILD_PYTHON_BINDINGS=${MLX_BUILD_PYTHON_BINDINGS}
             -DMLX_DATA_VERSION=${MLX_DATA_VERSION}
             -DCMAKE_MODULE_LINKER_FLAGS=${MLX_DATA_MODULE_LINKER_FLAGS})
```

----------------------------------------

TITLE: Finding BXZSTR Compression Dependencies
DESCRIPTION: Searches for necessary compression libraries (ZLIB, BZip2, LibLZMA) using the `find_package` command. These are dependencies required by the bxzstr library for different compression formats.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/CMakeLists.txt#_snippet_5

LANGUAGE: CMake
CODE:
```
find_package(ZLIB)
find_package(BZip2)
find_package(LibLZMA)
```

----------------------------------------

TITLE: Add/Build FFmpeg Dependency (CMake)
DESCRIPTION: Sets up the FFmpeg library as an external project dependency using ExternalProject_Add. It lists numerous dependencies (nasm, zlib, lame, etc.), specifies the download URL, and provides an extensive configure command with flags to disable various components and enable necessary ones (--prefix, --disable-shared, --enable-pic, --enable-libvorbis, etc.), along with custom build and install commands.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/super/CMakeLists.txt#_snippet_25

LANGUAGE: CMake
CODE:
```
ExternalProject_Add(
  ffmpeg
  DEPENDS nasm
          zlib
          lame
          libogg
          opus
          libvorbis
          xvidcore
          pkg-config
  URL https://ffmpeg.org/releases/ffmpeg-6.1.1.tar.bz2
  CONFIGURE_COMMAND
    PATH=${PATH} PKG_CONFIG_PATH=${PKG_CONFIG_PATH} ./configure
    --prefix=${CMAKE_BINARY_DIR}/deps --disable-shared --enable-pic
    --enable-runtime-cpudetect --enable-libvorbis --enable-libopus
    --disable-iconv --disable-programs --disable-doc --disable-htmlpages
    --disable-manpages --disable-podpages --disable-txtpages --disable-alsa
    --disable-sdl2 --disable-xlib --disable-cuda-llvm --disable-cuvid
    --disable-d3d11va --disable-dxva2 --disable-nvdec --disable-nvenc
    --disable-v4l2-m2m --disable-vdpau
    --pkg-config=${CMAKE_BINARY_DIR}/deps/bin/pkg-config
    --extra-ldflags=-L${CMAKE_BINARY_DIR}/deps/lib\ -L${CMAKE_BINARY_DIR}/deps/lib64
    --extra-libs=-lvorbis\ -logg\ -lm
  BUILD_COMMAND PATH=${CMAKE_BINARY_DIR}/deps/bin:$ENV{PATH} && make
  INSTALL_COMMAND make install
  BUILD_IN_SOURCE 1
  DOWNLOAD_EXTRACT_TIMESTAMP 1)
```

----------------------------------------

TITLE: Configuring BXZSTR Library Dependencies
DESCRIPTION: Creates an INTERFACE library target `bxzstr`. It then checks if each compression dependency (ZLIB, BZip2, LibLZMA) was found. If found, it adds their include directories and links their libraries to the `bxzstr` interface target and sets corresponding BXZSTR support flags. ZSTD support is explicitly disabled.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/CMakeLists.txt#_snippet_6

LANGUAGE: CMake
CODE:
```
add_library(bxzstr INTERFACE)
if(ZLIB_FOUND)
  target_include_directories(bxzstr INTERFACE ${ZLIB_INCLUDE_DIRS})
  target_link_libraries(bxzstr INTERFACE ${ZLIB_LIBRARIES})
  set(BXZSTR_Z_SUPPORT 1)
else()
  set(BXZSTR_Z_SUPPORT 0)
endif()
if(BZIP2_FOUND)
  target_include_directories(bxzstr INTERFACE ${BZIP2_INCLUDE_DIRS})
  target_link_libraries(bxzstr INTERFACE ${BZIP2_LIBRARIES})
  set(BXZSTR_BZ2_SUPPORT 1)
else()
  set(BXZSTR_BZ2_SUPPORT 0)
endif()
if(LIBLZMA_FOUND)
  target_include_directories(bxzstr INTERFACE ${LIBLZMA_INCLUDE_DIRS})
  target_link_libraries(bxzstr INTERFACE ${LIBLZMA_LIBRARIES})
  set(BXZSTR_LZMA_SUPPORT 1)
else()
  set(BXZSTR_LZMA_SUPPORT 0)
endif()
set(BXZSTR_ZSTD_SUPPORT 0)
```

----------------------------------------

TITLE: Add nasm External Project
DESCRIPTION: Adds nasm (Netwide Assembler) as an external project. It's downloaded, configured, built, and installed. This is noted as being needed on x86 by a few projects.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/super/CMakeLists.txt#_snippet_10

LANGUAGE: CMake
CODE:
```
ExternalProject_Add(
  nasm
  URL https://www.nasm.us/pub/nasm/releasebuilds/2.16.01/nasm-2.16.01.tar.xz
  CONFIGURE_COMMAND PATH=${PATH} PKG_CONFIG_PATH=${PKG_CONFIG_PATH} ./configure
                    --prefix=${CMAKE_BINARY_DIR}/deps
  BUILD_COMMAND make
  INSTALL_COMMAND make install
  BUILD_IN_SOURCE 1
  DOWNLOAD_EXTRACT_TIMESTAMP 1)
```

----------------------------------------

TITLE: Add libsndfile External Project
DESCRIPTION: Adds libsndfile as an external project with dependencies on flac, lame, libogg, libvorbis, mpg123, and pkg-config. It's downloaded and configured using CMake with options for release build, PIC, and disabling programs, examples, and cpack, installing to a custom prefix.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/super/CMakeLists.txt#_snippet_20

LANGUAGE: CMake
CODE:
```
ExternalProject_Add(
  libsndfile
  DEPENDS flac
          lame
          libogg
          libvorbis
          mpg123
          opus
          pkg-config
  URL https://github.com/libsndfile/libsndfile/releases/download/1.2.2/libsndfile-1.2.2.tar.xz
  CMAKE_ARGS -DCMAKE_BUILD_TYPE=Release
             -DBUILD_PROGRAMS=OFF
             -DBUILD_EXAMPLES=OFF
             -DENABLE_CPACK=OFF
             -DCMAKE_POSITION_INDEPENDENT_CODE=ON
             -DCMAKE_PREFIX_PATH=${CMAKE_BINARY_DIR}/deps
             -DCMAKE_INSTALL_PREFIX=${CMAKE_BINARY_DIR}/deps
  INSTALL_DIR ${CMAKE_BINARY_DIR}/deps
  DOWNLOAD_EXTRACT_TIMESTAMP 1)
```

----------------------------------------

TITLE: Add lame External Project
DESCRIPTION: Adds lame as an external project. It's downloaded, configured with position-independent code flags and installation prefix, built, and installed. Debugging, frontend, shared libraries, and gtktest are disabled.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/super/CMakeLists.txt#_snippet_17

LANGUAGE: CMake
CODE:
```
ExternalProject_Add(
  lame
  URL https://downloads.sourceforge.net/project/lame/lame/3.100/lame-3.100.tar.gz
  CONFIGURE_COMMAND
    PATH=${PATH} PKG_CONFIG_PATH=${PKG_CONFIG_PATH} CFLAGS=-fPIC ./configure
    --prefix=${CMAKE_BINARY_DIR}/deps --disable-debug --disable-frontend
    --disable-shared --disable-gtktest
  BUILD_COMMAND make
  INSTALL_COMMAND make install
  BUILD_IN_SOURCE 1
  DOWNLOAD_EXTRACT_TIMESTAMP 1)
```

----------------------------------------

TITLE: Fetching and Configuring STB Library
DESCRIPTION: Uses `FetchContent_Declare` to specify how to download the stb single-file libraries from GitHub via Git tag. It then checks if the content is populated and populates it if necessary. An INTERFACE library target `stb` is created, and its source directory is added as an include directory. No configuration or build commands are needed for this header-only library.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/CMakeLists.txt#_snippet_4

LANGUAGE: CMake
CODE:
```
FetchContent_Declare(
  stb
  GIT_REPOSITORY "https://github.com/nothings/stb.git"
  GIT_TAG "03f50e343d796e492e6579a11143a085429d7f5d"
  CONFIGURE_COMMAND "" BUILD_COMMAND "")
FetchContent_GetProperties(stb)
if(NOT stb_POPULATED)
  FetchContent_Populate(stb)
endif()
add_library(stb INTERFACE)
target_include_directories(stb INTERFACE ${stb_SOURCE_DIR})
```

----------------------------------------

TITLE: Add libiconv External Project
DESCRIPTION: Adds libiconv as an external project. It's downloaded, configured with position-independent code flags and installation prefix, built, and installed. Shared libraries are disabled.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/super/CMakeLists.txt#_snippet_6

LANGUAGE: CMake
CODE:
```
ExternalProject_Add(
  libiconv
  URL https://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.17.tar.gz
  CONFIGURE_COMMAND
    PATH=${PATH} PKG_CONFIG_PATH=${PKG_CONFIG_PATH} CFLAGS=-fPIC ./configure
    --prefix=${CMAKE_BINARY_DIR}/deps --disable-shared
  BUILD_COMMAND make
  INSTALL_COMMAND make install
  BUILD_IN_SOURCE 1
  DOWNLOAD_EXTRACT_TIMESTAMP 1)
```

----------------------------------------

TITLE: Add/Build Xvidcore Dependency (CMake)
DESCRIPTION: Configures CMake to download, patch, build, and install the xvidcore library using ExternalProject_Add. It specifies dependencies (nasm), the source URL, a patch command, custom configure/build/install commands with specific flags (-fPIC, --prefix), and build options.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/super/CMakeLists.txt#_snippet_24

LANGUAGE: CMake
CODE:
```
ExternalProject_Add(
  xvidcore
  DEPENDS nasm
  URL https://downloads.xvid.com/downloads/xvidcore-1.3.7.tar.bz2
  PATCH_COMMAND patch -p1 < ${CMAKE_SOURCE_DIR}/cmake/xvidcore-1.3.7.patch
  CONFIGURE_COMMAND
    cd build/generic && PATH=${PATH} PKG_CONFIG_PATH=${PKG_CONFIG_PATH}
    CFLAGS=-fPIC ./configure --prefix=${CMAKE_BINARY_DIR}/deps
  BUILD_COMMAND cd build/generic && make -j1
  INSTALL_COMMAND cd build/generic && make install
  BUILD_IN_SOURCE 1
  DOWNLOAD_EXTRACT_TIMESTAMP 1)
```

----------------------------------------

TITLE: Add opus External Project
DESCRIPTION: Adds opus as an external project. It's downloaded and configured using CMake with options for release build, static library, PIC, and disabling testing and programs, installing to a custom prefix.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/super/CMakeLists.txt#_snippet_16

LANGUAGE: CMake
CODE:
```
ExternalProject_Add(
  opus
  URL https://github.com/xiph/opus/releases/download/v1.4/opus-1.4.tar.gz
  CMAKE_ARGS -DCMAKE_BUILD_TYPE=Release
             -DOPUS_BUILD_SHARED_LIBRARY=OFF
             -DOPUS_BUILD_TESTING=OFF
             -DOPUS_BUILD_PROGRAMS=OFF
             -DCMAKE_POSITION_INDEPENDENT_CODE=ON
             -DCMAKE_PREFIX_PATH=${CMAKE_BINARY_DIR}/deps
             -DCMAKE_INSTALL_PREFIX=${CMAKE_BINARY_DIR}/deps
  INSTALL_DIR ${CMAKE_BINARY_DIR}/deps
  DOWNLOAD_EXTRACT_TIMESTAMP 1)
```

----------------------------------------

TITLE: Add libjpeg-turbo External Project
DESCRIPTION: Adds libjpeg-turbo as an external project with a dependency on nasm. It's downloaded and configured using CMake with specific options for release build, static library, PIC, and custom installation prefix.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/super/CMakeLists.txt#_snippet_11

LANGUAGE: CMake
CODE:
```
ExternalProject_Add(
  libjpeg-turbo
  DEPENDS nasm
  URL https://downloads.sourceforge.net/project/libjpeg-turbo/3.0.0/libjpeg-turbo-3.0.0.tar.gz
  CMAKE_ARGS -DCMAKE_BUILD_TYPE=Release
             -DENABLE_SHARED=OFF
             -DCMAKE_POSITION_INDEPENDENT_CODE=ON
             -DCMAKE_ASM_NASM_COMPILER=${CMAKE_BINARY_DIR}/deps/bin/nasm
             -DCMAKE_PREFIX_PATH=${CMAKE_BINARY_DIR}/deps
             -DCMAKE_INSTALL_PREFIX=${CMAKE_BINARY_DIR}/deps
  INSTALL_DIR ${CMAKE_BINARY_DIR}/deps
  DOWNLOAD_EXTRACT_TIMESTAMP 1)
```

----------------------------------------

TITLE: Add mpg123 External Project
DESCRIPTION: Adds mpg123 as an external project. It's downloaded, configured using the previously set options with position-independent code flags and installation prefix, built, and installed. Shared libraries and most components are disabled, enabling only the libmpg123 library.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/super/CMakeLists.txt#_snippet_19

LANGUAGE: CMake
CODE:
```
ExternalProject_Add(
  mpg123
  URL https://sourceforge.net/projects/mpg123/files/mpg123/1.32.3/mpg123-1.32.3.tar.bz2
  CONFIGURE_COMMAND
    PATH=${PATH} PKG_CONFIG_PATH=${PKG_CONFIG_PATH} CFLAGS=-fPIC ./configure
    --prefix=${CMAKE_BINARY_DIR}/deps --disable-shared --disable-components
    --enable-libmpg123 ${MPG123_COMPILE_OPTIONS}
  BUILD_COMMAND make
  INSTALL_COMMAND make install
  BUILD_IN_SOURCE 1
  DOWNLOAD_EXTRACT_TIMESTAMP 1)
```

----------------------------------------

TITLE: Add flac External Project
DESCRIPTION: Adds flac as an external project with dependencies on libogg and pkg-config. It's downloaded, patched to avoid certain dependencies, and configured using CMake with options for release build, static library, PIC, and disabling various components like documentation and programs.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/super/CMakeLists.txt#_snippet_14

LANGUAGE: CMake
CODE:
```
ExternalProject_Add(
  flac
  DEPENDS libogg pkg-config
  URL https://github.com/xiph/flac/releases/download/1.4.3/flac-1.4.3.tar.xz
  PATCH_COMMAND patch -p1 < ${CMAKE_SOURCE_DIR}/cmake/flac-1.4.3.patch
  CMAKE_ARGS -DCMAKE_BUILD_TYPE=Release
             -DINSTALL_MANPAGES=OFF
             -DBUILD_TESTING=OFF
             -DBUILD_PROGRAMS=OFF
             -DBUILD_EXAMPLES=OFF
             -DBUILD_DOCS=OFF
             -DBUILD_SHARED_LIBS=OFF
             -DCMAKE_POSITION_INDEPENDENT_CODE=ON
             -DCMAKE_PREFIX_PATH=${CMAKE_BINARY_DIR}/deps
             -DCMAKE_INSTALL_PREFIX=${CMAKE_BINARY_DIR}/deps
  INSTALL_DIR ${CMAKE_BINARY_DIR}/deps
  DOWNLOAD_EXTRACT_TIMESTAMP 1)
```

----------------------------------------

TITLE: Add libsamplerate External Project
DESCRIPTION: Adds libsamplerate as an external project. It's downloaded and configured using CMake with options for release build, static library, PIC, and disabling examples/testing, installing to a custom prefix.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/super/CMakeLists.txt#_snippet_12

LANGUAGE: CMake
CODE:
```
ExternalProject_Add(
  libsamplerate
  URL https://github.com/libsndfile/libsamplerate/archive/refs/tags/0.2.2.tar.gz
  CMAKE_ARGS -DCMAKE_BUILD_TYPE=Release
             -DBUILD_SHARED_LIBS=OFF
             -DLIBSAMPLERATE_EXAMPLES=OFF
             -DBUILD_TESTING=OFF
             -DCMAKE_POSITION_INDEPENDENT_CODE=ON
             -DCMAKE_PREFIX_PATH=${CMAKE_BINARY_DIR}/deps
             -DCMAKE_INSTALL_PREFIX=${CMAKE_BINARY_DIR}/deps
  INSTALL_DIR ${CMAKE_BINARY_DIR}/deps
  DOWNLOAD_EXTRACT_TIMESTAMP 1)
```


TITLE: Loading and Processing MNIST with MLX Data (Python)
DESCRIPTION: Demonstrates how to load the MNIST dataset using MLX Data's built-in loader and build a data processing pipeline. The pipeline shuffles the data, converts it to a stream, applies a key transformation to flatten and cast images, batches samples, and prefetches batches for efficiency. Finally, it shows how to iterate through the resulting batches.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/docs/src/quick_start.rst#_snippet_0

LANGUAGE: python
CODE:
```
# This is the standard way to import and access mlx.data
import mlx.data as dx

# Let's import MNIST loading
from mlx.data.datasets import load_mnist

# Loads a buffer with the MNIST images
mnist_train = load_mnist(train=True)

# Let's shuffle flatten and batch to prepare for MLP training
mnist_mlp = (
    mnist_train
    .shuffle()
    .to_stream()
    .key_transform("image", lambda x: x.astype("float32").reshape(-1))
    .batch(32)
    .prefetch(4, 2)
)

# Now we can iterate over the batches in normal python
for batch in mnist_mlp:
    x, y = batch["image"], batch["label"]

```

----------------------------------------

TITLE: Loading and Processing MNIST Dataset in MLX Data (Python)
DESCRIPTION: Demonstrates loading the MNIST dataset using `load_mnist` and setting up a basic data processing pipeline. The pipeline includes shuffling the data, converting it to a stream, transforming the image data (normalizing and flattening), batching samples, and prefetching for performance.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/docs/src/python/common_datasets.rst#_snippet_0

LANGUAGE: python
CODE:
```
import mlx.data as dx
from mlx.data.datasets import load_mnist, load_wikitext_lines
from mlx.data.tokenizer_helpers import read_trie_from_vocab

mnist = load_mnist()
print(mnist)
# Downloading http://yann.lecun.net/exdb/mnist/train-images-idx3-ubyte.gz 9.5MiB (15.1MiB/s)
# Downloading http://yann.lecun.net/exdb/mnist/t10k-images-idx3-ubyte.gz 1.6MiB (12.9MiB/s)
# Downloading http://yann.lecun.net/exdb/mnist/train-labels-idx1-ubyte.gz 32.0KiB (17.1MiB/s)
# Downloading http://yann.lecun.net/exdb/mnist/t10k-labels-idx1-ubyte.gz 8.0KiB (26.6MiB/s)
# Buffer(size=60000, keys={'label', 'image'})

mnist_iter = (
    mnist
    .shuffle()
    .to_stream()
    .key_transform("image", lambda x: (x.astype("float32") / 255).ravel())
    .batch(128)
    .prefetch(4, 2)
)
print(next(mnist_iter)["image"].shape)
# (128, 784)
```

----------------------------------------

TITLE: Loading and Tokenizing Wikitext-103 Dataset in MLX Data (Python)
DESCRIPTION: Shows how to load the wikitext-103 dataset, read a tokenizer trie from a vocabulary file, and build a complex data pipeline for natural language processing. The pipeline includes tokenization, filtering, prefetching, two stages of batching (one to gather tokens into an array, another for the final sample size), sliding window, and reshaping.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/docs/src/python/common_datasets.rst#_snippet_1

LANGUAGE: python
CODE:
```
wiki = load_wikitext_lines(split="train")
print(wiki)
# Downloading https://s3.amazonaws.com/research.metamind.io/wikitext/wikitext-103-raw-v1.zip 183.1MiB (9.9MiB/s)
# Computing hash of ..../.cache/mlx.data/wikitext/wikitext-103-raw-v1.zip |████████████████████████████████████████| 183.1MiB / 183.1MiB (1.0GiB/s)
# Extracting ..../.cache/mlx.data/wikitext/wikitext-103-raw-v1.zip 517.9MiB (318.2MiB/s)
# Stream()

workers = 8
trie = read_trie_from_vocab("/path/to/vocab.txt")
wiki_iterator = (
    wiki
    .tokenize("line", trie, output_key="tokens")
    .filter_key("tokens")
    .prefetch(512, workers)
    .batch(128, dim=dict(tokens=0))  # gather everything in a big array of tokens
    .sliding_window("tokens", 1025, 1025)
    .shape("tokens", "tokens_length", 0)
    .batch(32)  # actual batch size
    .prefetch(2, 1)
)
# The above can be iterated at approximately 2.5M tok/s on an M2 Macbook Air.
```

----------------------------------------

TITLE: Example Usage of MLX Streams for Training Epoch
DESCRIPTION: Demonstrates how to use the `hf_dataset_to_mlx_stream` function to create MLX streams for training and testing dataset splits. It resets the training stream, iterates through the first batch, converts the batch data to MLX arrays, prints the label of the first image, and displays the image using matplotlib for visualization.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/docs/src/hf_datasets_streams.rst#_snippet_11

LANGUAGE: python
CODE:
```
import matplotlib.pyplot as plt
import mlx.core as mx

train_stream = hf_dataset_to_mlx_stream(ds['train'], shuffle=True)
test_stream = hf_dataset_to_mlx_stream(ds['test'], shuffle=False)

train_stream.reset()
for batch in train_stream:
    (X, y) = mx.array(batch['image']), mx.array(batch['label'])

    print('The image should display a ', y[0].item())
    plt.imshow(X[0])
    break
```

----------------------------------------

TITLE: Helper Functions for Hugging Face to MLX Stream Conversion
DESCRIPTION: Provides two functions: `huggingface_to_array_of_dict` (same as previous definition) for converting dataset rows to NumPy dicts, and `hf_dataset_to_mlx_stream` which wraps the conversion to buffer and stream creation, including optional shuffling and common stream operations like normalization, batching, and prefetching.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/docs/src/hf_datasets_streams.rst#_snippet_10

LANGUAGE: python
CODE:
```
import numpy as np
import mlx.data as dx

# Convert the content of the dataset into numpy arrays
def huggingface_to_array_of_dict(dataset):
    return [{"image": np.array(image).copy(), "label": label}
            for label, image in zip(dataset['label'], dataset['image'])]

# Convert the Hugging Face dataset to a stream of batches
def hf_dataset_to_mlx_stream(dataset, shuffle=False):
    numpy_data = huggingface_to_array_of_dict(dataset)

    buffer = dx.buffer_from_vector(numpy_data)
    if shuffle:
        buffer = buffer.shuffle()

    return (
        buffer
        .to_stream()
        .key_transform("image", lambda x: x.astype("float32") / 255)
        .batch(32)
        .prefetch(prefetch_size=8, num_threads=4)
    )
```

----------------------------------------

TITLE: Using and Transforming Stream in MLX Data Python
DESCRIPTION: This snippet demonstrates how to create a large stream from a Python iterable using `dx.stream_python_iterable`, apply transformations like filtering using `sample_transform`, and access elements sequentially with `next()`. It also shows that streams are mutable stateful objects, and resetting a stream allows re-iteration from the beginning. Requires the `mlx.data` library.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/docs/src/python/stream.rst#_snippet_0

LANGUAGE: python
CODE:
```
import mlx.data as dx

# The samples are never all instantiated
numbers = dx.stream_python_iterable(lambda: ({"x": i} for i in range(10**10)))

# Filtering is done with transforms returning an empty sample
evens = numbers.sample_transform(lambda s: s if s["x"] % 2 == 0 else dict())

print(next(numbers))
# prints {'x': array(0)}
print(next(numbers))
# prints {'x': array(1)}

# Streams are pointers to the streams so evens is using numbers under the
# hood. Since numbers was advanced now evens is advanced as well.
print(next(evens))
# prints {'x': array(2)}
print(next(evens))
# prints {'x': array(4)}
print(next(numbers))
# prints {'x': array(5)}

# Streams can be reset.
evens.reset()
print(next(evens))
print(next(evens))
print(next(numbers))
# prints {'x': array(0)}
#        {'x': array(2)}
#        {'x': array(3)}
```

----------------------------------------

TITLE: Building MLX Data Pipeline - Python
DESCRIPTION: This snippet demonstrates how to create a data loading and preprocessing pipeline using the MLX Data library in Python. It starts with a helper function `files_and_classes` to generate a list of sample dictionaries containing file paths and labels. This list is then used to create a MLX Data buffer, which is subsequently transformed into a shuffled stream. The stream is processed through image operations (loading, resizing, cropping), batched, and key-transformed to normalize image data before being prefetched for efficient iteration.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/README.md#_snippet_0

LANGUAGE: Python
CODE:
```
# A simple python function returning a list of dicts. All samples in MLX data
# are dicts of arrays.
def files_and_classes(root: Path):
    files = [str(f) for f in root.glob("**/*.jpg")]
    files = [f for f in files if "BACKGROUND" not in f]
    classes = dict(
        map(reversed, enumerate(sorted(set(f.split("/")[-2] for f in files))))
    )

    return [
        dict(image=f.encode("ascii"), label=classes[f.split("/")[-2]]) for f in files
    ]

dset = (
    # Make a buffer (finite length container of samples) from the python list
    dx.buffer_from_vector(files_and_classes(root))

    # Shuffle and transform to a stream
    .shuffle()
    .to_stream()

    # Implement a simple image pipeline. No random augmentations here but they
    # could be applied.
    .load_image("image")  # load the file pointed to by the 'image' key as an image
    .image_resize_smallest_side("image", 256)
    .image_center_crop("image", 224, 224)

    # Accumulate into batches
    .batch(batch_size)

    # Cast to float32 and scale to [0, 1]. We do this in python and we could
    # have done any transformation we could think of.
    .key_transform("image", lambda x: x.astype("float32") / 255)

    # Finally, fetch batches in background threads
    .prefetch(prefetch_size=8, num_threads=8)
)

# dset is a python iterable so one could simply
for sample in dset:
    # access sample["image"] and sample["label"]
    pass
```

----------------------------------------

TITLE: Creating and Accessing mlx.data Buffer in Python
DESCRIPTION: This snippet demonstrates how to create an mlx.data Buffer from a Python list of dictionaries, apply a key transformation to modify sample values, and then access basic properties like printing the buffer representation, accessing a specific element by index, and getting the buffer's size.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/docs/src/python/buffer.rst#_snippet_0

LANGUAGE: python
CODE:
```
import mlx.data as dx

numbers = dx.buffer_from_vector([{"x": i} for i in range(10)])
evens = numbers.key_transform("x", lambda x: 2*x)

print(evens)
# prints Buffer(size=10, keys={'x'})

print(evens[3])
# prints {'x': array(6)}

print(len(evens))
# prints 10
```

----------------------------------------

TITLE: Installing MLX Data with pip (Bash)
DESCRIPTION: Installs the MLX Data package from the Python Package Index (PyPI). This command fetches the pre-built package, including necessary dependencies for reading various file types and S3 content on compatible systems (Linux, Apple silicon Macs).
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/docs/src/install.rst#_snippet_0

LANGUAGE: Bash
CODE:
```
pip install mlx-data
```

----------------------------------------

TITLE: Installing Hugging Face Datasets
DESCRIPTION: This command uses pip, the Python package installer, to install the `datasets` library from the Python Package Index (PyPI). This is a prerequisite for downloading and loading datasets from the Hugging Face Hub.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/docs/src/hf_datasets_streams.rst#_snippet_0

LANGUAGE: bash
CODE:
```
pip install datasets
```

----------------------------------------

TITLE: Creating Buffer from List - MLX Data - Python
DESCRIPTION: Demonstrates creating an MLX Buffer from a Python list of samples generated by a helper function. It uses `dx.buffer_from_vector` with the output of a function that processes image files and their categories, showing how to structure samples for a dataset.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/docs/src/buffers_streams_samples.rst#_snippet_1

LANGUAGE: python
CODE:
```
from pathlib import Path

import mlx.data as dx

def files_and_classes(root: Path):
    """Load the files and classes from an image dataset that contains one folder per class."""
    images = list(root.rglob("*.jpg"))
    categories = [p.relative_to(root).parent.name for p in images]
    category_set = set(categories)
    category_map = {c: i for i, c in enumerate(sorted(category_set))}

    return [
        {
            "image": str(p.relative_to(root)).encode("ascii"),
            "category": c,
            "label": category_map[c]
        }
        for c, p in zip(categories, images)
    ]

dset = dx.buffer_from_vector(files_and_classes(Path("path/to/dataset)))
# We can now apply transformations to the dataset
```

----------------------------------------

TITLE: Processing Buffer as Stream with Prefetch - MLX Data - Python
DESCRIPTION: Shows how to transform an MLX Buffer into a Stream using `.to_stream()` to enable stream-specific operations like batching and non-deterministic prefetching. It demonstrates chaining operations: shuffle, convert to stream, batch, and prefetch for efficient iteration.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/docs/src/buffers_streams_samples.rst#_snippet_2

LANGUAGE: python
CODE:
```
# We can define the rest of the processing pipeline using streams.
# 1. First shuffle the buffer
# 2. Make a stream
# 3. Batch and then prefetch
dset = (
    dset
    .shuffle()
    .to_stream()  # <-- making a stream from the shuffled buffer
    .batch(32)
    .prefetch(8, 4)  # <-- prefetch 8 batches using 4 threads
)

# Now we can iterate over dset
sample = next(dset)
```

----------------------------------------

TITLE: Creating an MLX Buffer from a List of Dictionaries
DESCRIPTION: Imports the MLX data library as `dx`. It then uses the `dx.buffer_from_vector()` function to convert a Python list of dictionaries, where values are typically NumPy arrays or other standard types, into an MLX Buffer object. This Buffer is the intermediate representation before creating a Stream.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/docs/src/hf_datasets_streams.rst#_snippet_7

LANGUAGE: python
CODE:
```
import mlx.data as dx

buffer = dx.buffer_from_vector(dicts)
```

----------------------------------------

TITLE: Creating an MLX Stream with Transformations and Batching
DESCRIPTION: Converts the MLX Buffer into an MLX Stream using `.to_stream()`. It chains several operations: `key_transform` normalizes the 'image' data to float32 in the range [0, 1], `batch` groups samples into batches of size 32, and `prefetch` enables background loading of batches with 8 batches preloaded using 4 threads.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/docs/src/hf_datasets_streams.rst#_snippet_8

LANGUAGE: python
CODE:
```
stream = buffer
    .to_stream()
    .key_transform("image", lambda x: x.astype("float32") / 255)
    .batch(32)
    .prefetch(prefetch_size=8, num_threads=4)
```

----------------------------------------

TITLE: Loading a Dataset from Hugging Face
DESCRIPTION: Imports the `load_dataset` function from the Hugging Face `datasets` library and uses it to download and load the 'ylecun/mnist' dataset. It then prints the loaded dataset object, specifically focusing on the 'train' split to show its structure.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/docs/src/hf_datasets_streams.rst#_snippet_1

LANGUAGE: python
CODE:
```
from datasets import load_dataset

ds = load_dataset("ylecun/mnist")
print(ds['train'])
```

----------------------------------------

TITLE: Defining MLX Samples - MLX Data - Python
DESCRIPTION: Shows various ways to define a sample dictionary in MLX data. Samples are dictionaries mapping string keys to values that are cast to MLX arrays, including numpy arrays, scalars, and strings (bytes recommended for paths or raw data).
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/docs/src/buffers_streams_samples.rst#_snippet_0

LANGUAGE: python
CODE:
```
# This is a valid sample
sample = {"hello": np.array(0)}

# So is this because scalars are cast to scalar arrays
sample = {"scalar": 42}

# Strings can also be used, however, they will be represented in unicode.
sample = {"key": "value"}

# Most likely you would want to write it as bytes in the sample as follows
sample = {"key": b"path/to/my/file"}
sample = {"key": "value".encode("ascii")}
```

----------------------------------------

TITLE: Initialize and Use AWSFileFetcher Python
DESCRIPTION: This snippet demonstrates how to initialize the `AWSFileFetcher` class with bucket details, an optional endpoint, a local cache directory, and cache size. It shows examples of fetching a single file synchronously using `fetch` and initiating background downloads for multiple files using `prefetch`.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/docs/src/python/miscellaneous.rst#_snippet_0

LANGUAGE: python
CODE:
```
from pathlib import Path
from mlx.data.core import AWSFileFetcher

LOCAL_CACHE = Path("/path/to/local/cache")

ff = AWSFileFetcher(
    "my-cool-bucket",
    endpoint="https://my.endpoint.com/"
    local_prefix=LOCAL_CACHE,
    num_kept_files=100,
)

# When fetch returns my/remote/path/foo.npy will be in LOCAL_CACHE
ff.fetch("my/remote/path/foo.npy")
assert (LOCAL_CACHE / "my/remote/path/foo.npy").is_file()

# We can prefetch in the background
ff.prefetch(["foo_1.npy", "foo_2.npy"])
ff.fetch("foo_1.npy")
# process foo_1 while foo_2 downloads in the background
```

----------------------------------------

TITLE: Applying Python Transforms in MLX Data (Python)
DESCRIPTION: Illustrates examples of using Python functions within MLX Data pipelines for custom transformations and filtering. This includes normalizing image data using `key_transform` with a lambda function, applying an audio feature extraction function (`mfsc`), and filtering samples based on a condition using `sample_transform`.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/docs/src/quick_start.rst#_snippet_1

LANGUAGE: python
CODE:
```
# Normalizing images in [0, 1]
dset = dset.key_transform("image", lambda x: x.astype("float32") / 255)

# Extracting mel spectrogram features
# A big chunk of the time is spent computing the FFT which is done with the GIL off so...
from mlx.data.features import mfsc
dset = dset.key_transform("audio", mfsc(n_filterbank=80, sampling_freq=16000))

# Filter stream samples based on values (empty dict means drop the sample)
dset = dset.sample_transform(lambda s: s if s["length"] > 10 else dict())

```

----------------------------------------

TITLE: Building MLX Data Python Bindings (pip/Bash)
DESCRIPTION: Navigates to the MLX Data source directory and uses pip to build and install the Python library along with its required C++ backend. The `-e .` option is mentioned as an alternative for an editable install suitable for development.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/docs/src/install.rst#_snippet_5

LANGUAGE: Bash
CODE:
```
cd /path/to/mlx/data
pip install .  # or pip install -e . for an editable install
```

----------------------------------------

TITLE: Loading CharTrie from SPM File & Tokenizing (Python)
DESCRIPTION: This snippet illustrates how to load a `CharTrie` and corresponding token weights from a SentencePiece model file using the `read_trie_from_spm` helper. It then creates a `Tokenizer` using the loaded trie and weights, demonstrating how to prepare a tokenizer based on a pre-trained model for efficient tokenization.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/docs/src/python/tokenizing.rst#_snippet_2

LANGUAGE: python
CODE:
```
from mlx.data.tokenizer_helpers import read_trie_from_spm

trie, weights = read_trie_from_spm("path/to/spm/model")
tokenizer = Tokenizer(trie, trie_key_scores=weights)
tokenizer.tokenize_shortest(b"This is some more text to tokenize")
```

----------------------------------------

TITLE: Using key_transform in MLX Stream
DESCRIPTION: Highlights the `.key_transform("image", ...)` operation within an MLX Stream pipeline. This function applies a specified lambda function (or any callable) to the data associated with the key 'image' for each sample processed by the stream. It's used here for preprocessing like normalization or reshaping.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/docs/src/hf_datasets_streams.rst#_snippet_9

LANGUAGE: python
CODE:
```
.key_transform("image", ...)
```

----------------------------------------

TITLE: Installing MLX Data Dependencies (apt/Ubuntu)
DESCRIPTION: Installs core optional system dependencies required for specific MLX Data functionalities (audio, video, images, compression) on Ubuntu using the apt package manager. This command covers libraries for sound, video, images, and compression.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/docs/src/install.rst#_snippet_2

LANGUAGE: Bash
CODE:
```
sudo apt install libsndfile1-dev libsamplerate0-dev ffmpeg libjpeg-turbo8-dev \
    zlib1g-dev libbz2-dev liblzma-dev
```

----------------------------------------

TITLE: Applying Conditional Transformations with mlx.data Python
DESCRIPTION: This Python snippet demonstrates how to chain conditional transformation methods (`*_if`) on an mlx.data buffer (`dset`). It applies transformations like image loading, conditional random cropping, conditional horizontal flipping, and conditional key transformation (brightness adjustment) based on boolean flags or probabilities, allowing for pipeline configuration without redirection.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/docs/src/python/dataset.rst#_snippet_0

LANGUAGE: python
CODE:
```
# Assuming we have a buffer with image files and labels in dset
dset = (
    dset
    .load_image("image_file", output_key="image")
    .image_random_crop_if(enable_random_crop, "image", 256, 256)
    .image_random_h_flip_if(flip_prob > 0, "image", flip_prob)
    .key_transform_if(brightness_range > 0, "image",
                      lambda x: ((1 + brightness_range * np.random.rand(x.shape[:2])[..., None]) * x).astype(x.dtype))
)
```

----------------------------------------

TITLE: Adding Characters to CharTrie & Tokenizing (Python)
DESCRIPTION: This demonstrates adding individual lowercase and uppercase ASCII letters as single-character tokens to an existing `CharTrie`. It then tokenizes a new byte string using the same `Tokenizer`, showing how the extended vocabulary in the trie influences the resulting token sequence.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/docs/src/python/tokenizing.rst#_snippet_1

LANGUAGE: python
CODE:
```
import string
for l in string.ascii_letters:
    trie.insert(bytes(l, "utf-8"))

print(tokenizer.tokenize_shortest(b"This is a quick example"))
```

----------------------------------------

TITLE: Converting Hugging Face Dataset to List of Dicts with NumPy Arrays
DESCRIPTION: Defines a Python function `huggingface_to_array_of_dict` that iterates through a Hugging Face dataset split. For each sample, it converts the image (assumed to be a PIL Image) to a NumPy array using `np.array()` and creates a dictionary containing the 'image' array and the 'label'. It returns a list of these dictionaries, suitable for MLX Buffer creation.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/docs/src/hf_datasets_streams.rst#_snippet_5

LANGUAGE: python
CODE:
```
import numpy as np

def huggingface_to_array_of_dict(dataset):
    return [{"image": np.array(image).copy(), "label": label}
            for label, image in zip(dataset['label'], dataset['image'])]
```

----------------------------------------

TITLE: Building & Using CharTrie Manually (Python)
DESCRIPTION: This snippet shows how to initialize a `CharTrie` and insert byte sequences (tokens) into it. It then demonstrates creating a `Tokenizer` with this trie and using the `tokenize_shortest` method to tokenize an input byte string, outputting a list of corresponding integer indices.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/docs/src/python/tokenizing.rst#_snippet_0

LANGUAGE: python
CODE:
```
from mlx.data.core import CharTrie, Tokenizer

# We can build a trie ourselves
trie = CharTrie()
for t in b"a quick brown fox jumped over the lazy dog".split():
    trie.insert(t)
trie.insert(b" ")

tokenizer = Tokenizer(trie)
print(tokenizer.tokenize_shortest(b"a quick brown fox jumped over the lazy dog"))
```

----------------------------------------

TITLE: Processing Buffer with Ordered Prefetch - MLX Data - Python
DESCRIPTION: Demonstrates applying batching and deterministic prefetching directly to an MLX Buffer using `.ordered_prefetch()`. This method implicitly converts the buffer to a stream while ensuring a specific processing order, suitable when deterministic iteration is required.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/docs/src/buffers_streams_samples.rst#_snippet_3

LANGUAGE: python
CODE:
```
# We can define the rest of the processing pipeline using streams.
# 1. First shuffle the buffer
# 2. Make a stream
# 3. Batch and then prefetch
dset = (
    dset
    .shuffle()
    .batch(32)
    .ordered_prefetch(8, 4)  # <-- prefetch 8 batches in a stream using 4 threads
)

# Now we can iterate over dset
sample = next(dset)
```

----------------------------------------

TITLE: Converting Dataset and Verifying Output Structure
DESCRIPTION: Calls the `huggingface_to_array_of_dict` function to convert a dataset split (represented by the variable `dataset`) into the desired list of dictionaries. Includes `assert` statements to programmatically verify that the output `dicts` is indeed a list, contains dictionaries, and that the 'image' key in the first dictionary holds a NumPy array.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/docs/src/hf_datasets_streams.rst#_snippet_6

LANGUAGE: python
CODE:
```
dicts = huggingface_to_array_of_dict(dataset)

assert type(dicts) == list
assert type(dicts[0]) == dict
assert type(dicts[0]['image']) == np.ndarray
```

----------------------------------------

TITLE: Installing MLX Data Dependencies (Homebrew/macOS)
DESCRIPTION: Installs optional system dependencies required for specific MLX Data functionalities (audio, video, images, compression, S3 access) on macOS using the Homebrew package manager. Without these, corresponding features might not be built or available.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/docs/src/install.rst#_snippet_1

LANGUAGE: Bash
CODE:
```
brew install libsndfile libsamplerate ffmpeg jpeg-turbo zlib bzip2 xz aws-sdk-cpp
```

----------------------------------------

TITLE: Installing MLX Data Build Tools (pip/Bash)
DESCRIPTION: Installs the necessary Python packages, pybind11 (for creating Python bindings to C++ code) and CMake (a build system generator), using pip. These tools are prerequisites for building the MLX Data Python library from source.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/docs/src/install.rst#_snippet_4

LANGUAGE: Bash
CODE:
```
pip install pybind11[global] cmake
```

----------------------------------------

TITLE: Configuring Pybind11 Module Target in CMake
DESCRIPTION: This snippet defines a CMake target named `_c` using `pybind11_add_module`, listing the necessary C++ source files for the Python bindings. It then configures the target by adding include directories, linking it against the required `mlxdata` library, defining a compiler preprocessor macro for the version, and specifying the installation path within the `mlx/data` directory.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/python/src/CMakeLists.txt#_snippet_0

LANGUAGE: CMake
CODE:
```
pybind11_add_module(
  _c
  ${CMAKE_CURRENT_LIST_DIR}/wrap.cpp
  ${CMAKE_CURRENT_LIST_DIR}/wrap_buffer.cpp
  ${CMAKE_CURRENT_LIST_DIR}/wrap_core.cpp
  ${CMAKE_CURRENT_LIST_DIR}/wrap_stream.cpp)

target_include_directories(_c PUBLIC ${CMAKE_SOURCE_DIR})
target_link_libraries(_c PRIVATE mlxdata)
target_compile_definitions(_c PRIVATE _VERSION_=${MLX_DATA_VERSION})

install(TARGETS _c DESTINATION mlx/data)
```

----------------------------------------

TITLE: Fetching and Configuring pybind11
DESCRIPTION: This block is conditional on the `MLX_BUILD_PYTHON_BINDINGS` option. If enabled, it finds the Python interpreter and development libraries. It defines a patch command for pybind11, declares and fetches pybind11 from GitHub, applies the patch, and adds the fetched pybind11 source directory as a subdirectory to integrate its build system.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/CMakeLists.txt#_snippet_8

LANGUAGE: CMake
CODE:
```
if(MLX_BUILD_PYTHON_BINDINGS)
  find_package(Python COMPONENTS Interpreter Development.Module)

  # avoid warning regarding FindPythonInterp and FindPythonLibs modules which
  # are deprecated from CMake 3.27
  set(pybind11_patch git apply
                     ${CMAKE_CURRENT_SOURCE_DIR}/cmake/pybind11-v2.11.1.patch)
  FetchContent_Declare(
    pybind11
    GIT_REPOSITORY https://github.com/pybind/pybind11
    GIT_TAG v2.11.1
    # patch is always applied, so we silently fail if already patched
    PATCH_COMMAND ${pybind11_patch} || true)

  FetchContent_GetProperties(pybind11)
  if(NOT pybind11_POPULATED)
    FetchContent_Populate(pybind11)
    add_subdirectory(${pybind11_SOURCE_DIR} ${pybind11_BINARY_DIR})
  endif()
endif()
```

----------------------------------------

TITLE: Checking Image Data Type in Dataset
DESCRIPTION: This Python code snippet accesses the 'train' split of the loaded dataset and attempts to print the type of the elements within the 'image' column. This is done to inspect the initial format of the image data, which is often a library-specific object like a PIL Image.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/docs/src/hf_datasets_streams.rst#_snippet_3

LANGUAGE: python
CODE:
```
print(type(ds['train']['image']))
```

----------------------------------------

TITLE: Building Standalone MLX Data C++ Library (CMake/Bash)
DESCRIPTION: Provides shell commands to create a build directory, configure the C++ project using CMake, compile the library using Make, and install the resulting static library and headers into the system's default locations. This allows using MLX Data as a dependency in other C++ projects.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/docs/src/install.rst#_snippet_6

LANGUAGE: Bash
CODE:
```
mkdir build && cd build
cmake ..
make -j
sudo make install
```

----------------------------------------

TITLE: Running MLX Data WikiText Benchmark (bash)
DESCRIPTION: This command executes the main `mlx_data.py` script with specific parameters via bash. It sets the `OMP_NUM_THREADS` environment variable to 1 and passes the path to the SentencePiece tokenizer model and the directory containing the extracted WikiText103 dataset. This runs the MLX data processing benchmark.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/benchmarks/comparative/wikitext/README.md#_snippet_1

LANGUAGE: bash
CODE:
```
OMP_NUM_THREADS=1 python mlx_data.py \
    --tokenizer_file /path/to/tokenizer.model \
    /path/to/wikitext/wikitext-103-raw
```

----------------------------------------

TITLE: Running LibriSpeech Benchmark Script (Bash)
DESCRIPTION: Executes the provided bash script `run_librispeech.sh` to automate the data download, tokenizer setup, and benchmark execution process for the LibriSpeech dataset. This script simplifies the setup and running procedure. Requires `wget` and `unzip` dependencies if data needs downloading.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/benchmarks/comparative/librispeech/README.md#_snippet_0

LANGUAGE: bash
CODE:
```
bash run_librispeech.sh
```

----------------------------------------

TITLE: Run Caltech 101 Benchmark Script - Bash
DESCRIPTION: Executes the `run_caltech.sh` Bash script. This script is designed to automate the process of downloading the Caltech 101 dataset, extracting it, and then running the benchmark tests sequentially using the extracted data. Requires `wget` and `unzip` dependencies to handle data download and extraction.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/benchmarks/comparative/caltech101/README.md#_snippet_0

LANGUAGE: bash
CODE:
```
bash run_caltech.sh
```

----------------------------------------

TITLE: Building and Installing AWS SDK for S3 (Bash/Ubuntu)
DESCRIPTION: Provides a sequence of shell commands to build and install the AWS SDK for C++ from source on Ubuntu, specifically configured to include only the S3 component as a static library. This manual step is required for S3 access support when building MLX Data from source on Ubuntu if pre-built binaries are not used.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/docs/src/install.rst#_snippet_3

LANGUAGE: Bash
CODE:
```
sudo apt install libcurl4-openssl-dev libssl-dev
git clone --depth 1 --recurse-submodules https://github.com/aws/aws-sdk-cpp.git
cd aws-sdk-cpp
mkdir build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release -DBUILD_ONLY="s3" -DBUILD_SHARED_LIBS=OFF
make -j
sudo make install
```

----------------------------------------

TITLE: Formatting C++ File with clang-format (Shell)
DESCRIPTION: Demonstrates how to format a specific C++ source file (`file.cpp`) in-place using the `clang-format` command-line tool. The `-i` flag indicates in-place editing. This ensures consistent C++ code style and requires `clang-format` to be installed.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/CONTRIBUTING.md#_snippet_0

LANGUAGE: Shell
CODE:
```
clang-format -i file.cpp
```

----------------------------------------

TITLE: Add curl External Project
DESCRIPTION: Adds curl as an external project with dependencies on openssl and pkg-config. It's downloaded, configured with position-independent code flags and installation prefix, built, and installed. Shared libraries and LDAP support are disabled, enabling SSL support via the built openssl.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/super/CMakeLists.txt#_snippet_22

LANGUAGE: CMake
CODE:
```
ExternalProject_Add(
  curl
  URL https://curl.se/download/curl-8.5.0.tar.bz2
  DEPENDS openssl pkg-config
  CONFIGURE_COMMAND
    PATH=${PATH} PKG_CONFIG_PATH=${PKG_CONFIG_PATH} CFLAGS=-fPIC ./configure
    --disable-shared --with-openssl --disable-ldap
    --prefix=${CMAKE_BINARY_DIR}/deps
  BUILD_COMMAND make
  INSTALL_COMMAND make install
  BUILD_IN_SOURCE 1
  DOWNLOAD_EXTRACT_TIMESTAMP 1)
```

----------------------------------------

TITLE: Add openssl External Project
DESCRIPTION: Adds openssl as an external project. It's downloaded, configured with position-independent code flags and installation prefix, built, and installed. Shared libraries, specific ciphers (idea, mdc2, rc5), and tests are disabled.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/super/CMakeLists.txt#_snippet_21

LANGUAGE: CMake
CODE:
```
ExternalProject_Add(
  openssl
  URL https://www.openssl.org/source/openssl-1.1.1q.tar.gz
  CONFIGURE_COMMAND
    PATH=${PATH} PKG_CONFIG_PATH=${PKG_CONFIG_PATH} CFLAGS=-fPIC ./config
    no-shared no-idea no-mdc2 no-rc5 no-tests --prefix=${CMAKE_BINARY_DIR}/deps
  BUILD_COMMAND make depend && make
  INSTALL_COMMAND make install_sw
  BUILD_IN_SOURCE 1
  DOWNLOAD_EXTRACT_TIMESTAMP 1)
```

----------------------------------------

TITLE: Add AWS S3 SDK External Project
DESCRIPTION: Adds the AWS SDK for C++ (specifically the S3 component) as an external project with dependencies on openssl, curl, and pkg-config. It's cloned from Git, patched, and configured using CMake with options for release build, static library, PIC, and disabling testing, installing to a custom prefix.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/super/CMakeLists.txt#_snippet_23

LANGUAGE: CMake
CODE:
```
ExternalProject_Add(
  aws-s3
  GIT_REPOSITORY https://github.com/aws/aws-sdk-cpp.git
  GIT_TAG 1.11.231
  GIT_SHALLOW 1
  PATCH_COMMAND patch -p1 < ${CMAKE_SOURCE_DIR}/cmake/aws-1.11.231.patch
  DEPENDS openssl curl pkg-config
  CMAKE_ARGS -DCMAKE_BUILD_TYPE=Release
             -DBUILD_ONLY=s3
             -DBUILD_SHARED_LIBS=OFF
             -DBUILD_TESTING=OFF
             -DAUTORUN_UNIT_TESTS=OFF
             -DENABLE_TESTING=OFF
             -DCMAKE_POSITION_INDEPENDENT_CODE=ON
             -DCMAKE_PREFIX_PATH=${CMAKE_BINARY_DIR}/deps
             -DCMAKE_INSTALL_PREFIX=${CMAKE_BINARY_DIR}/deps
  INSTALL_DIR ${CMAKE_BINARY_DIR}/deps
  DOWNLOAD_EXTRACT_TIMESTAMP 1)
```

----------------------------------------

TITLE: Fetching and Configuring BXZSTR Library
DESCRIPTION: Defines a command to apply a patch file to the bxzstr source. `FetchContent_Declare` is used to download bxzstr from GitHub via Git tag, applying the defined patch. It populates the content if needed, configures the `config.hpp` file using `configure_file` based on found dependencies, and adds the source directory to the interface include directories.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/CMakeLists.txt#_snippet_7

LANGUAGE: CMake
CODE:
```
set(bxzstr_patch git apply ${CMAKE_CURRENT_SOURCE_DIR}/cmake/bxzstr.patch)
FetchContent_Declare(
  bxzstr
  GIT_REPOSITORY "https://github.com/tmaklin/bxzstr.git"
  GIT_TAG "a6e5d743b5547a3ec23fd842813dec8067c8aff1"
  # patch is always applied, so we silently fail if already patched
  PATCH_COMMAND ${bxzstr_patch} || true CONFIGURE_COMMAND "" BUILD_COMMAND "")
FetchContent_GetProperties(bxzstr)
if(NOT bxzstr_POPULATED)
  FetchContent_Populate(bxzstr)
  configure_file(${bxzstr_SOURCE_DIR}/bxzstr/config.hpp.in
                 ${bxzstr_SOURCE_DIR}/bxzstr/config.hpp)
endif()
target_include_directories(bxzstr INTERFACE ${bxzstr_SOURCE_DIR})
```

----------------------------------------

TITLE: Build MLX Data Project (CMake)
DESCRIPTION: Adds the main mlx-data project as an external build target using ExternalProject_Add. It doesn't download but uses CMake commands to remove a directory and create a symlink to the source. It depends on previously built libraries and passes several CMake arguments to configure the sub-build, including paths, build type, and linker flags determined earlier.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/super/CMakeLists.txt#_snippet_27

LANGUAGE: CMake
CODE:
```
# CMake does not like when source dir depends on targets which are in a
# subdirectory of the top source dir. We thus make a symlink in the build dir to
# avoid any error message (CMake also create the directory mlx-data beforehand,
# expecting it to be populated -- we remove this directory first in that
# respect)
ExternalProject_Add(
  mlx-data
  DOWNLOAD_COMMAND
    ${CMAKE_COMMAND} -E remove_directory mlx-data && ${CMAKE_COMMAND} -E
    create_symlink ${CMAKE_SOURCE_DIR}/.. mlx-data
  UPDATE_COMMAND ""
  DEPENDS zlib
          bzip2
          xz
          libsndfile
          libsamplerate
          libjpeg-turbo
          ffmpeg
          aws-s3
  CMAKE_ARGS -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
             -DCMAKE_PREFIX_PATH=${CMAKE_BINARY_DIR}/deps
             -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}
             -DMLX_BUILD_PYTHON_BINDINGS=${MLX_BUILD_PYTHON_BINDINGS}
             -DMLX_DATA_VERSION=${MLX_DATA_VERSION}
             -DCMAKE_MODULE_LINKER_FLAGS=${MLX_DATA_MODULE_LINKER_FLAGS})
```

----------------------------------------

TITLE: Finding BXZSTR Compression Dependencies
DESCRIPTION: Searches for necessary compression libraries (ZLIB, BZip2, LibLZMA) using the `find_package` command. These are dependencies required by the bxzstr library for different compression formats.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/CMakeLists.txt#_snippet_5

LANGUAGE: CMake
CODE:
```
find_package(ZLIB)
find_package(BZip2)
find_package(LibLZMA)
```

----------------------------------------

TITLE: Add/Build FFmpeg Dependency (CMake)
DESCRIPTION: Sets up the FFmpeg library as an external project dependency using ExternalProject_Add. It lists numerous dependencies (nasm, zlib, lame, etc.), specifies the download URL, and provides an extensive configure command with flags to disable various components and enable necessary ones (--prefix, --disable-shared, --enable-pic, --enable-libvorbis, etc.), along with custom build and install commands.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/super/CMakeLists.txt#_snippet_25

LANGUAGE: CMake
CODE:
```
ExternalProject_Add(
  ffmpeg
  DEPENDS nasm
          zlib
          lame
          libogg
          opus
          libvorbis
          xvidcore
          pkg-config
  URL https://ffmpeg.org/releases/ffmpeg-6.1.1.tar.bz2
  CONFIGURE_COMMAND
    PATH=${PATH} PKG_CONFIG_PATH=${PKG_CONFIG_PATH} ./configure
    --prefix=${CMAKE_BINARY_DIR}/deps --disable-shared --enable-pic
    --enable-runtime-cpudetect --enable-libvorbis --enable-libopus
    --disable-iconv --disable-programs --disable-doc --disable-htmlpages
    --disable-manpages --disable-podpages --disable-txtpages --disable-alsa
    --disable-sdl2 --disable-xlib --disable-cuda-llvm --disable-cuvid
    --disable-d3d11va --disable-dxva2 --disable-nvdec --disable-nvenc
    --disable-v4l2-m2m --disable-vdpau
    --pkg-config=${CMAKE_BINARY_DIR}/deps/bin/pkg-config
    --extra-ldflags=-L${CMAKE_BINARY_DIR}/deps/lib\ -L${CMAKE_BINARY_DIR}/deps/lib64
    --extra-libs=-lvorbis\ -logg\ -lm
  BUILD_COMMAND PATH=${CMAKE_BINARY_DIR}/deps/bin:$ENV{PATH} && make
  INSTALL_COMMAND make install
  BUILD_IN_SOURCE 1
  DOWNLOAD_EXTRACT_TIMESTAMP 1)
```

----------------------------------------

TITLE: Configuring BXZSTR Library Dependencies
DESCRIPTION: Creates an INTERFACE library target `bxzstr`. It then checks if each compression dependency (ZLIB, BZip2, LibLZMA) was found. If found, it adds their include directories and links their libraries to the `bxzstr` interface target and sets corresponding BXZSTR support flags. ZSTD support is explicitly disabled.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/CMakeLists.txt#_snippet_6

LANGUAGE: CMake
CODE:
```
add_library(bxzstr INTERFACE)
if(ZLIB_FOUND)
  target_include_directories(bxzstr INTERFACE ${ZLIB_INCLUDE_DIRS})
  target_link_libraries(bxzstr INTERFACE ${ZLIB_LIBRARIES})
  set(BXZSTR_Z_SUPPORT 1)
else()
  set(BXZSTR_Z_SUPPORT 0)
endif()
if(BZIP2_FOUND)
  target_include_directories(bxzstr INTERFACE ${BZIP2_INCLUDE_DIRS})
  target_link_libraries(bxzstr INTERFACE ${BZIP2_LIBRARIES})
  set(BXZSTR_BZ2_SUPPORT 1)
else()
  set(BXZSTR_BZ2_SUPPORT 0)
endif()
if(LIBLZMA_FOUND)
  target_include_directories(bxzstr INTERFACE ${LIBLZMA_INCLUDE_DIRS})
  target_link_libraries(bxzstr INTERFACE ${LIBLZMA_LIBRARIES})
  set(BXZSTR_LZMA_SUPPORT 1)
else()
  set(BXZSTR_LZMA_SUPPORT 0)
endif()
set(BXZSTR_ZSTD_SUPPORT 0)
```

----------------------------------------

TITLE: Add nasm External Project
DESCRIPTION: Adds nasm (Netwide Assembler) as an external project. It's downloaded, configured, built, and installed. This is noted as being needed on x86 by a few projects.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/super/CMakeLists.txt#_snippet_10

LANGUAGE: CMake
CODE:
```
ExternalProject_Add(
  nasm
  URL https://www.nasm.us/pub/nasm/releasebuilds/2.16.01/nasm-2.16.01.tar.xz
  CONFIGURE_COMMAND PATH=${PATH} PKG_CONFIG_PATH=${PKG_CONFIG_PATH} ./configure
                    --prefix=${CMAKE_BINARY_DIR}/deps
  BUILD_COMMAND make
  INSTALL_COMMAND make install
  BUILD_IN_SOURCE 1
  DOWNLOAD_EXTRACT_TIMESTAMP 1)
```

----------------------------------------

TITLE: Add libsndfile External Project
DESCRIPTION: Adds libsndfile as an external project with dependencies on flac, lame, libogg, libvorbis, mpg123, and pkg-config. It's downloaded and configured using CMake with options for release build, PIC, and disabling programs, examples, and cpack, installing to a custom prefix.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/super/CMakeLists.txt#_snippet_20

LANGUAGE: CMake
CODE:
```
ExternalProject_Add(
  libsndfile
  DEPENDS flac
          lame
          libogg
          libvorbis
          mpg123
          opus
          pkg-config
  URL https://github.com/libsndfile/libsndfile/releases/download/1.2.2/libsndfile-1.2.2.tar.xz
  CMAKE_ARGS -DCMAKE_BUILD_TYPE=Release
             -DBUILD_PROGRAMS=OFF
             -DBUILD_EXAMPLES=OFF
             -DENABLE_CPACK=OFF
             -DCMAKE_POSITION_INDEPENDENT_CODE=ON
             -DCMAKE_PREFIX_PATH=${CMAKE_BINARY_DIR}/deps
             -DCMAKE_INSTALL_PREFIX=${CMAKE_BINARY_DIR}/deps
  INSTALL_DIR ${CMAKE_BINARY_DIR}/deps
  DOWNLOAD_EXTRACT_TIMESTAMP 1)
```

----------------------------------------

TITLE: Add lame External Project
DESCRIPTION: Adds lame as an external project. It's downloaded, configured with position-independent code flags and installation prefix, built, and installed. Debugging, frontend, shared libraries, and gtktest are disabled.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/super/CMakeLists.txt#_snippet_17

LANGUAGE: CMake
CODE:
```
ExternalProject_Add(
  lame
  URL https://downloads.sourceforge.net/project/lame/lame/3.100/lame-3.100.tar.gz
  CONFIGURE_COMMAND
    PATH=${PATH} PKG_CONFIG_PATH=${PKG_CONFIG_PATH} CFLAGS=-fPIC ./configure
    --prefix=${CMAKE_BINARY_DIR}/deps --disable-debug --disable-frontend
    --disable-shared --disable-gtktest
  BUILD_COMMAND make
  INSTALL_COMMAND make install
  BUILD_IN_SOURCE 1
  DOWNLOAD_EXTRACT_TIMESTAMP 1)
```

----------------------------------------

TITLE: Fetching and Configuring STB Library
DESCRIPTION: Uses `FetchContent_Declare` to specify how to download the stb single-file libraries from GitHub via Git tag. It then checks if the content is populated and populates it if necessary. An INTERFACE library target `stb` is created, and its source directory is added as an include directory. No configuration or build commands are needed for this header-only library.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/CMakeLists.txt#_snippet_4

LANGUAGE: CMake
CODE:
```
FetchContent_Declare(
  stb
  GIT_REPOSITORY "https://github.com/nothings/stb.git"
  GIT_TAG "03f50e343d796e492e6579a11143a085429d7f5d"
  CONFIGURE_COMMAND "" BUILD_COMMAND "")
FetchContent_GetProperties(stb)
if(NOT stb_POPULATED)
  FetchContent_Populate(stb)
endif()
add_library(stb INTERFACE)
target_include_directories(stb INTERFACE ${stb_SOURCE_DIR})
```

----------------------------------------

TITLE: Add libiconv External Project
DESCRIPTION: Adds libiconv as an external project. It's downloaded, configured with position-independent code flags and installation prefix, built, and installed. Shared libraries are disabled.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/super/CMakeLists.txt#_snippet_6

LANGUAGE: CMake
CODE:
```
ExternalProject_Add(
  libiconv
  URL https://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.17.tar.gz
  CONFIGURE_COMMAND
    PATH=${PATH} PKG_CONFIG_PATH=${PKG_CONFIG_PATH} CFLAGS=-fPIC ./configure
    --prefix=${CMAKE_BINARY_DIR}/deps --disable-shared
  BUILD_COMMAND make
  INSTALL_COMMAND make install
  BUILD_IN_SOURCE 1
  DOWNLOAD_EXTRACT_TIMESTAMP 1)
```

----------------------------------------

TITLE: Add/Build Xvidcore Dependency (CMake)
DESCRIPTION: Configures CMake to download, patch, build, and install the xvidcore library using ExternalProject_Add. It specifies dependencies (nasm), the source URL, a patch command, custom configure/build/install commands with specific flags (-fPIC, --prefix), and build options.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/super/CMakeLists.txt#_snippet_24

LANGUAGE: CMake
CODE:
```
ExternalProject_Add(
  xvidcore
  DEPENDS nasm
  URL https://downloads.xvid.com/downloads/xvidcore-1.3.7.tar.bz2
  PATCH_COMMAND patch -p1 < ${CMAKE_SOURCE_DIR}/cmake/xvidcore-1.3.7.patch
  CONFIGURE_COMMAND
    cd build/generic && PATH=${PATH} PKG_CONFIG_PATH=${PKG_CONFIG_PATH}
    CFLAGS=-fPIC ./configure --prefix=${CMAKE_BINARY_DIR}/deps
  BUILD_COMMAND cd build/generic && make -j1
  INSTALL_COMMAND cd build/generic && make install
  BUILD_IN_SOURCE 1
  DOWNLOAD_EXTRACT_TIMESTAMP 1)
```

----------------------------------------

TITLE: Add opus External Project
DESCRIPTION: Adds opus as an external project. It's downloaded and configured using CMake with options for release build, static library, PIC, and disabling testing and programs, installing to a custom prefix.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/super/CMakeLists.txt#_snippet_16

LANGUAGE: CMake
CODE:
```
ExternalProject_Add(
  opus
  URL https://github.com/xiph/opus/releases/download/v1.4/opus-1.4.tar.gz
  CMAKE_ARGS -DCMAKE_BUILD_TYPE=Release
             -DOPUS_BUILD_SHARED_LIBRARY=OFF
             -DOPUS_BUILD_TESTING=OFF
             -DOPUS_BUILD_PROGRAMS=OFF
             -DCMAKE_POSITION_INDEPENDENT_CODE=ON
             -DCMAKE_PREFIX_PATH=${CMAKE_BINARY_DIR}/deps
             -DCMAKE_INSTALL_PREFIX=${CMAKE_BINARY_DIR}/deps
  INSTALL_DIR ${CMAKE_BINARY_DIR}/deps
  DOWNLOAD_EXTRACT_TIMESTAMP 1)
```

----------------------------------------

TITLE: Add libjpeg-turbo External Project
DESCRIPTION: Adds libjpeg-turbo as an external project with a dependency on nasm. It's downloaded and configured using CMake with specific options for release build, static library, PIC, and custom installation prefix.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/super/CMakeLists.txt#_snippet_11

LANGUAGE: CMake
CODE:
```
ExternalProject_Add(
  libjpeg-turbo
  DEPENDS nasm
  URL https://downloads.sourceforge.net/project/libjpeg-turbo/3.0.0/libjpeg-turbo-3.0.0.tar.gz
  CMAKE_ARGS -DCMAKE_BUILD_TYPE=Release
             -DENABLE_SHARED=OFF
             -DCMAKE_POSITION_INDEPENDENT_CODE=ON
             -DCMAKE_ASM_NASM_COMPILER=${CMAKE_BINARY_DIR}/deps/bin/nasm
             -DCMAKE_PREFIX_PATH=${CMAKE_BINARY_DIR}/deps
             -DCMAKE_INSTALL_PREFIX=${CMAKE_BINARY_DIR}/deps
  INSTALL_DIR ${CMAKE_BINARY_DIR}/deps
  DOWNLOAD_EXTRACT_TIMESTAMP 1)
```

----------------------------------------

TITLE: Add mpg123 External Project
DESCRIPTION: Adds mpg123 as an external project. It's downloaded, configured using the previously set options with position-independent code flags and installation prefix, built, and installed. Shared libraries and most components are disabled, enabling only the libmpg123 library.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/super/CMakeLists.txt#_snippet_19

LANGUAGE: CMake
CODE:
```
ExternalProject_Add(
  mpg123
  URL https://sourceforge.net/projects/mpg123/files/mpg123/1.32.3/mpg123-1.32.3.tar.bz2
  CONFIGURE_COMMAND
    PATH=${PATH} PKG_CONFIG_PATH=${PKG_CONFIG_PATH} CFLAGS=-fPIC ./configure
    --prefix=${CMAKE_BINARY_DIR}/deps --disable-shared --disable-components
    --enable-libmpg123 ${MPG123_COMPILE_OPTIONS}
  BUILD_COMMAND make
  INSTALL_COMMAND make install
  BUILD_IN_SOURCE 1
  DOWNLOAD_EXTRACT_TIMESTAMP 1)
```

----------------------------------------

TITLE: Add flac External Project
DESCRIPTION: Adds flac as an external project with dependencies on libogg and pkg-config. It's downloaded, patched to avoid certain dependencies, and configured using CMake with options for release build, static library, PIC, and disabling various components like documentation and programs.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/super/CMakeLists.txt#_snippet_14

LANGUAGE: CMake
CODE:
```
ExternalProject_Add(
  flac
  DEPENDS libogg pkg-config
  URL https://github.com/xiph/flac/releases/download/1.4.3/flac-1.4.3.tar.xz
  PATCH_COMMAND patch -p1 < ${CMAKE_SOURCE_DIR}/cmake/flac-1.4.3.patch
  CMAKE_ARGS -DCMAKE_BUILD_TYPE=Release
             -DINSTALL_MANPAGES=OFF
             -DBUILD_TESTING=OFF
             -DBUILD_PROGRAMS=OFF
             -DBUILD_EXAMPLES=OFF
             -DBUILD_DOCS=OFF
             -DBUILD_SHARED_LIBS=OFF
             -DCMAKE_POSITION_INDEPENDENT_CODE=ON
             -DCMAKE_PREFIX_PATH=${CMAKE_BINARY_DIR}/deps
             -DCMAKE_INSTALL_PREFIX=${CMAKE_BINARY_DIR}/deps
  INSTALL_DIR ${CMAKE_BINARY_DIR}/deps
  DOWNLOAD_EXTRACT_TIMESTAMP 1)
```

----------------------------------------

TITLE: Add libsamplerate External Project
DESCRIPTION: Adds libsamplerate as an external project. It's downloaded and configured using CMake with options for release build, static library, PIC, and disabling examples/testing, installing to a custom prefix.
SOURCE: https://github.com/ml-explore/mlx-data/blob/main/super/CMakeLists.txt#_snippet_12

LANGUAGE: CMake
CODE:
```
ExternalProject_Add(
  libsamplerate
  URL https://github.com/libsndfile/libsamplerate/archive/refs/tags/0.2.2.tar.gz
  CMAKE_ARGS -DCMAKE_BUILD_TYPE=Release
             -DBUILD_SHARED_LIBS=OFF
             -DLIBSAMPLERATE_EXAMPLES=OFF
             -DBUILD_TESTING=OFF
             -DCMAKE_POSITION_INDEPENDENT_CODE=ON
             -DCMAKE_PREFIX_PATH=${CMAKE_BINARY_DIR}/deps
             -DCMAKE_INSTALL_PREFIX=${CMAKE_BINARY_DIR}/deps
  INSTALL_DIR ${CMAKE_BINARY_DIR}/deps
  DOWNLOAD_EXTRACT_TIMESTAMP 1)
```

TITLE: MLX Swift Evaluation and Automatic Differentiation Functions
DESCRIPTION: This section covers functions for evaluating MLX arrays and performing automatic differentiation. It includes methods for eager evaluation, asynchronous evaluation, computing gradients (`grad`), computing values and gradients (`valueAndGrad`), stopping gradient flow, and performing Jacobian-vector products (`jvp`) and vector-Jacobian products (`vjp`).
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/free-functions.md#_snippet_12

LANGUAGE: APIDOC
CODE:
```
- ``eval(_:)-190w1``
- ``eval(_:)-3b2g9``
- ``eval(_:)-8fexv``
- ``eval(_:)-91pbd``
- ``asyncEval(_:)-6j4zg``
- ``asyncEval(_:)-6uc2e``
- ``asyncEval(_:)-11gzm``
- ``grad(_:)-r8dv``
- ``grad(_:)-7z6i``
- ``grad(_:argumentNumbers:)-2ictk``
- ``grad(_:argumentNumbers:)-5va2g``
- ``valueAndGrad(_:)``
- ``valueAndGrad(_:argumentNumbers:)``
- ``stopGradient(_:stream:)``
- ``jvp(_:primals:tangents:)``
- ``vjp(_:primals:cotangents:)``
```

----------------------------------------

TITLE: Print to stdout using fmt::print (C++)
DESCRIPTION: Demonstrates how to print a simple 'Hello, world!' message to standard output using the `fmt::print` function from the `fmt` library. Requires including `<fmt/core.h>`.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/README.md#_snippet_0

LANGUAGE: C++
CODE:
```
#include <fmt/core.h>

int main() {
  fmt::print("Hello, world!\n");
}
```

----------------------------------------

TITLE: Create and Inspect MLXArray in Swift
DESCRIPTION: This Swift code demonstrates how to create an MLXArray from a standard Swift array, inspect its data type (dtype) and shape, and perform basic arithmetic operations like multiplication and square root. It showcases the fundamental usage of MLXArray for numerical computations.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/MLXArray.md#_snippet_0

LANGUAGE: swift
CODE:
```
// create an array from a swift array
let a1 = MLXArray([1, 2, 3])

// this holds Int32
print(a1.dtype)

// and has a shape of [3]
print(a1.shape)

// there are a variety of operators and functions that can be used
let a2 = sqrt(a1 * 3)
```

----------------------------------------

TITLE: MLXOptimizers Available Optimizers Reference
DESCRIPTION: This section lists the various built-in optimizers provided by MLXOptimizers, including common algorithms like Adam, SGD, and RMSprop. These optimizers are essential for updating model weights during the training process.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLXOptimizers/Documentation.docc/MLXOptimizers.md#_snippet_1

LANGUAGE: APIDOC
CODE:
```
Optimizers:
  - AdaDelta
  - Adafactor
  - AdaGrad
  - AdamW
  - Adam
  - Adamax
  - Lion
  - RMSprop
  - SGD
```

----------------------------------------

TITLE: MLXNN Module Class API Documentation
DESCRIPTION: Comprehensive API documentation for the `Module` class in MLXNN, detailing its purpose, key methods for parameter management, and inspection capabilities. This includes methods for extracting, freezing, updating, and mapping parameters within a module hierarchy.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLXNN/Documentation.docc/custom-layers.md#_snippet_6

LANGUAGE: APIDOC
CODE:
```
Module Class:
  Description: The core class for composing neural network layers in MLX Swift, acting as a container for MLXArray or other Module instances. It provides mechanisms to recursively access and update parameters of itself and its submodules.

  Methods:
    parameters():
      Description: Extracts a NestedDictionary (ModuleParameters) containing all parameters of the module and its submodules.
      Returns: NestedDictionary (ModuleParameters)

    freeze(recursive: Bool, keys: [String], strict: Bool):
      Description: Marks parameters as 'frozen' so they are not considered during gradient computation and weight updates.
      Parameters:
        recursive: If true, freezes parameters in submodules.
        keys: Specific keys of parameters to freeze.
        strict: If true, raises an error if a specified key is not found.

    update(parameters: ModuleParameters, verify: Bool):
      Description: Updates a large subset of a module's parameters.
      Parameters:
        parameters: The new parameters to apply.
        verify: If true, verifies the parameters before updating.

    mapParameters(map: (MLXArray) -> Any, isLeaf: (Any) -> Bool):
      Description: Applies a mapping function to all parameters within the module, allowing for detailed inspection (e.g., viewing shapes or types).
      Parameters:
        map: A function to apply to each parameter.
        isLeaf: A function to determine if a node is a leaf.
```

----------------------------------------

TITLE: MLX Swift: Compiling a Full Training Step
DESCRIPTION: This snippet demonstrates how to compile an entire training step, encompassing forward pass, backward pass, and parameter updates, into a single optimized function. By capturing the model and optimizer state in `inputs` and `outputs`, the training process can be significantly accelerated.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/Articles/compilation.md#_snippet_12

LANGUAGE: swift
CODE:
```
let step = compile(inputs: [model, optimizer], outputs: [model, optimizer]) { x, y in
    let (loss, grads) = lg(model, x, y)
    optimizer.update(model: model, gradients: grads)
    return loss
}

for _ in 0 ..< 30 {
    // prepare the training data
    let x = MLXRandom.uniform(low: -5.0, high: 5.0, [10, 1])
    let y = m * x + b
    eval(x, y)

    let loss = step(x, y)
}
```

----------------------------------------

TITLE: Convert RMSNorm Layer from Python to Swift
DESCRIPTION: This snippet demonstrates the conversion of an RMSNorm layer from Python to Swift. The Python version uses `__init__` for initialization and `__call__` for the forward pass, dynamically creating properties. The Swift equivalent uses declared instance variables (`let weight`, `let eps`), a standard `init` method, and `callAsFunction` to mimic the callable behavior. It also shows the conversion of `mx.ones` to `MLXArray.ones` and `mx.rsqrt` to `rsqrt`.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLXNN/Documentation.docc/custom-layers.md#_snippet_10

LANGUAGE: Python
CODE:
```
class RMSNorm(nn.Module):
    def __init__(self, dims: int, eps: float = 1e-5):
        super().__init__()
        self.weight = mx.ones((dims,))
        self.eps = eps

    def _norm(self, x):
        return x * mx.rsqrt(x.square().mean(-1, keepdims=True) + self.eps)

    def __call__(self, x):
        output = self._norm(x.astype(mx.float32)).astype(x.dtype)
        return self.weight * output
```

LANGUAGE: Swift
CODE:
```
public class RMSNorm : Module {

    // swift uses declared ivars rather than properties dynamically created in init
    let weight: MLXArray
    let eps: Float

    public init(_ dimensions: Int, eps: Float = 1e-5) {
        self.weight = MLXArray.ones([dimensions])
        self.eps = eps
        super.init()
    }

    // we can use `internal` (default) or `private` functions for internal implementation
    func norm(_ x: MLXArray) -> MLXArray {
        x * rsqrt(x.square().mean(axis: -1, keepDims: true) + self.eps)
    }

    // this is the equivalent of the `__call__()` method from python and it
    // allows use like:
    //
    // let result = norm(input)
    public func callAsFunction(_ x: MLXArray) -> MLXArray {
        let output = norm(x.asType(.float32)).asType(x.dtype)
        return weight * output
    }
```

----------------------------------------

TITLE: MLX Swift Built-in Loss Functions API Reference
DESCRIPTION: Provides a comprehensive list of built-in loss functions available in MLX Swift, detailing their names and parameters. These functions are crucial for training machine learning models by quantifying the difference between predicted and actual values, enabling optimization of model performance.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLXNN/Documentation.docc/losses.md#_snippet_0

LANGUAGE: APIDOC
CODE:
```
MLX Swift Loss Functions:
- binaryCrossEntropy(logits:targets:weights:withLogits:reduction:)
- cosineSimilarityLoss(x1:x2:axis:eps:reduction:)
- crossEntropy(logits:targets:weights:axis:labelSmoothing:reduction:)
- hingeLoss(inputs:targets:reduction:)
- huberLoss(inputs:targets:delta:reduction:)
- klDivLoss(inputs:targets:axis:reduction:)
- l1Loss(predictions:targets:reduction:)
- logCoshLoss(inputs:targets:reduction:)
- mseLoss(predictions:targets:reduction:)
- nllLoss(inputs:targets:axis:reduction:)
- smoothL1Loss(predictions:targets:beta:reduction:)
- tripletLoss(anchors:positives:negatives:axis:p:margin:eps:reduction:)
```

----------------------------------------

TITLE: Run Model Training Loop with SGD in MLX Swift
DESCRIPTION: This Swift code implements the main training loop. For a set number of epochs, it generates random training data, computes the loss and gradients using the 'lg' function, and updates the model's parameters with the 'SGD' optimizer.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLXNN/Documentation.docc/training.md#_snippet_4

LANGUAGE: swift
CODE:
```
// run a number of epochs
for _ in 0 ..< 30 {
    print("target: b = \(b), m = \(m)")
    print("parameters: \(model.parameters())")

    // generate random training data along with the ground truth.
    // notice that the shape is [B, 1] where B is the batch
    // dimension -- this allows us to train on 10 samples simultaneously
    let x = MLXRandom.uniform(low: -5.0, high: 5.0, [10, 1])
    let y = f(x)
    eval(x, y)

    // compute the loss and gradients.  use the optimizer
    // to adjust the parameters closer to the target
    let (loss, grads) = lg(model, x, y)
    optimizer.update(model: model, gradients: grads)

    eval(model, optimizer)
}
```

----------------------------------------

TITLE: Basic String Formatting with fmt::format
DESCRIPTION: Demonstrates the fundamental usage of `fmt::format` to create a formatted string, similar to Python's `str.format`. It returns a `std::string`.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/doc/index.rst#_snippet_0

LANGUAGE: C++
CODE:
```
std::string s = fmt::format("The answer is {}.", 42);
```

----------------------------------------

TITLE: Initialize Model, Loss-Gradient Function, and Optimizer in MLX Swift
DESCRIPTION: This Swift code block initializes the 'LinearFunctionModel', creates a function 'lg' using 'valueAndGrad' to compute both loss and gradients, and sets up an SGD optimizer with a specified learning rate for parameter updates.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLXNN/Documentation.docc/training.md#_snippet_2

LANGUAGE: swift
CODE:
```
let model = LinearFunctionModel()
eval(model)

// compute the loss and gradients
let lg = valueAndGrad(model: model, loss)

// the optimizer will use the gradients update the model parameters
let optimizer = SGD(learningRate: 1e-1)
```

----------------------------------------

TITLE: Implementing a Simple Training Loop with MLXOptimizers in Swift
DESCRIPTION: This Swift code demonstrates a basic training loop using MLXOptimizers. It defines a loss function, computes gradients, and updates model parameters iteratively using an SGD optimizer. The example highlights the core steps of model training with MLX.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLXOptimizers/Documentation.docc/MLXOptimizers.md#_snippet_0

LANGUAGE: Swift
CODE:
```
func loss(model: Model, x: MLXArray, y: MLXArray) -> MLXArray {
    // choose the loss function
    mseLoss(predictions: model(x), targets: y, reduction: .mean)
}

// function to compute the value (loss) and gradient
let lg = valueAndGrad(model: model, loss)

let optimizer = SGD(learningRate: 1e-1)

for _ in 0 ..< epochs {
    let (x, y) = ...

    // evaluate the training data
    let (loss, grads) = lg(model, x, y)

    // use the optimizer to update the model parameters
    optimizer.update(model: model, gradients: grads)

    eval(model, optimizer)
}
```

----------------------------------------

TITLE: MLXArray Operators and Element-wise Arithmetic Functions API Reference
DESCRIPTION: A comprehensive reference for the arithmetic operators and element-wise mathematical functions available on the MLXArray class in MLX Swift. This includes binary operators, logical comparison operators, bitwise operators, and various common mathematical functions.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/Organization/arithmetic.md#_snippet_3

LANGUAGE: APIDOC
CODE:
```
MLXArray Operators:
- MLXArray/+(_:_:)
- MLXArray/-(_:)
- MLXArray/*(_:_:)
- MLXArray/**(_:_:)
- MLXArray/%(_:_:)
- MLXArray/.!(_:)
- MLXArray/.==(_:_:)
- MLXArray/.!=(_:_:)
- MLXArray/.<(_:_:)
- MLXArray/.<=(_:_:)
- MLXArray/.>(_:_:)
- MLXArray/.>=(_:_:)
- MLXArray/.&&(_:_:)
- MLXArray/.||(_:_:)
- MLXArray/&(_:_:)
- MLXArray/|(_:_:)
- MLXArray/^(_:_:)
- MLXArray/<<(_:_:)
- MLXArray/>>(_:_:)

MLXArray Element-wise Arithmetic Functions:
- MLXArray/abs(stream:)
- MLXArray/conjugate(stream:)
- MLXArray/cos(stream:)
- MLXArray/exp(stream:)
- MLXArray/floor(stream:)
- MLXArray/floorDivide(_:stream:)
- MLXArray/log(stream:)
- MLXArray/log2(stream:)
- MLXArray/log10(stream:)
- MLXArray/log1p(stream:)
- MLXArray/pow(_:stream:)
- MLXArray/reciprocal(stream:)
- MLXArray/rsqrt(stream:)
- MLXArray/round(decimals:stream:)
- MLXArray/sin(stream:)
- MLXArray/sqrt(stream:)
- MLXArray/square(stream:)
```

----------------------------------------

TITLE: MLXArray Basic Indexing Operations in Swift
DESCRIPTION: This snippet demonstrates various basic indexing operations supported by MLXArray in Swift, including integer indexing, range expressions, full range slices, strides, ellipsis, newaxis, and using another MLXArray as an index. It highlights the Swift syntax equivalents for common Python indexing patterns.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/Organization/indexing.md#_snippet_0

LANGUAGE: Swift
CODE:
```
let array = MLXArray(0 ..< 512, [8, 8, 8])

// index by integer
array[1]

// index by multiple integers
array[1, 3]

// index by range expression
// python: [1:5]
array[1 ..< 5]

// full range slice
// python: [:]
array[0 ...]

// slice with stride of 2
// python: [::2]
array[.stride(by: 2)]

// ellipsis operator (consume all remaining axes)
// python: [..., 3]
array[.ellipsis, 3]

// newaxis operator (insert a new axis of size 1)
// python: [None]
array[.newAxis]

// using another MLXArray as an index
let i = MLXArray([1, 2])
array[i]
```

----------------------------------------

TITLE: Benchmark Regular vs. Compiled Gelu Function in Swift MLX
DESCRIPTION: This snippet demonstrates how to benchmark the performance of the `gelu` function both in its regular form and after compilation using MLX's `compile` function. It initializes a large MLXArray and uses the `measure` helper to compare their runtimes, showcasing the speedup achieved by compilation.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/Articles/compilation.md#_snippet_3

LANGUAGE: Swift
CODE:
```
let x = MLXRandom.uniform(0 ..< 1, [32, 1000, 4096])

measure(gelu, x)
measure(compile(gelu), x)
```

----------------------------------------

TITLE: MLX Swift: Capturing Implicit State with compile(outputs:)
DESCRIPTION: A more convenient method for handling implicit state is to use the `outputs` parameter of the `compile` function. This allows the compiled function to capture and update external state variables, such as `MLXArray` arrays, without requiring them to be returned explicitly.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/Articles/compilation.md#_snippet_7

LANGUAGE: swift
CODE:
```
var state = [MLXArray]()

func f(_ x: MLXArray) -> MLXArray {
    let z = x * 8
    state.append(z)
    return exp(z)
}

// capture state the `state` array as a side effect
let compiled = compile(outputs: [state], f)
_ = compiled(MLXArray(1.0))

print(state)
```

----------------------------------------

TITLE: Creating MLX Arrays in Unified Memory (Swift)
DESCRIPTION: Demonstrates how MLX arrays are created. These arrays automatically reside in unified memory, accessible by both CPU and GPU without explicit device specification, simplifying memory management.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/Articles/unified-memory.md#_snippet_0

LANGUAGE: Swift
CODE:
```
let a = MLXRandom.normal([100])
let b = MLXRandom.normal([100])
```

----------------------------------------

TITLE: Define a Linear Function Model in MLX Swift
DESCRIPTION: This Swift class defines a simple linear function model (y = mx + b) using MLX. It initializes 'm' (slope) and 'b' (intercept) with random uniform values and implements the 'callAsFunction' method to compute the linear output.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLXNN/Documentation.docc/training.md#_snippet_0

LANGUAGE: swift
CODE:
```
// A very simple model that implements the equation
// for a linear function: y = mx + b.  This can be trained
// to match data -- in this case an unknown (to the model)
// linear function.
//
// This is a nice example because most people know how
// linear functions work and we can see how the slope
// and intercept converge.
class LinearFunctionModel: Module, UnaryLayer {
    let m = MLXRandom.uniform(low: -5.0, high: 5.0)
    let b = MLXRandom.uniform(low: -5.0, high: 5.0)

    func callAsFunction(_ x: MLXArray) -> MLXArray {
        m * x + b
    }
}
```

----------------------------------------

TITLE: MLX Swift: Uncompiled Training Loop Example
DESCRIPTION: This example illustrates a basic training loop without compilation. It outlines the iterative steps involved in preparing training data, evaluating the loss and gradients using `valueAndGrad`, and updating the model parameters with an optimizer.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/Articles/compilation.md#_snippet_11

LANGUAGE: swift
CODE:
```
for _ in 0 ..< 30 {
    // prepare the training data
    let x = MLXRandom.uniform(low: -5.0, high: 5.0, [10, 1])
    let y = m * x + b
    eval(x, y)

    // evaluate and update parameters
    let (loss, grads) = lg(model, x, y)
    optimizer.update(model: model, gradients: grads)
}
```

----------------------------------------

TITLE: Basic Vectorization with vmap in MLX Swift
DESCRIPTION: This snippet demonstrates the fundamental usage of `vmap` to apply a function `f` element-wise over the first axis of an `MLXArray`. It shows how `vmap` simplifies batch operations compared to explicit looping and stacking, producing identical results.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/Articles/vmap.md#_snippet_0

LANGUAGE: Swift
CODE:
```
func f(_ x: MLXArray) -> MLXArray { x * 2 }

let x = MLXArray(0 ..< 6, [3, 2])

let vf = vmap(f)
let y = vf(x)
```

LANGUAGE: Swift
CODE:
```
let manual = stacked((0 ..< 3).map { f(x[$0]) }, axis: 0)
```

----------------------------------------

TITLE: Add MLX Swift Product Dependencies to SwiftPM
DESCRIPTION: This snippet demonstrates how to link specific MLX Swift libraries (MLX, MLXRandom, MLXNN, MLXOptimizers, MLXFFT) as product dependencies within your Swift Package Manager project after adding the main package.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/install.md#_snippet_1

LANGUAGE: Swift
CODE:
```
dependencies: [.product(name: "MLX", package: "mlx-swift"),
               .product(name: "MLXRandom", package: "mlx-swift"),
               .product(name: "MLXNN", package: "mlx-swift"),
               .product(name: "MLXOptimizers", package: "mlx-swift"),
               .product(name: "MLXFFT", package: "mlx-swift")]
```

----------------------------------------

TITLE: Define Mean Squared Error Loss Function in MLX Swift
DESCRIPTION: This Swift function calculates the mean squared error (MSE) loss between model predictions and ground truth targets. It uses 'mseLoss' from MLX to quantify the distance, providing feedback for model training.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLXNN/Documentation.docc/training.md#_snippet_1

LANGUAGE: swift
CODE:
```
// measure the distance from the prediction (model(x)) and the
// ground truth (y).  this gives feedback on how close the
// prediction is from matching the truth
func loss(model: LinearFunctionModel, x: MLXArray, y: MLXArray) -> MLXArray {
    mseLoss(predictions: model(x), targets: y, reduction: .mean)
}
```

----------------------------------------

TITLE: Performing Operations on Different Devices (Swift)
DESCRIPTION: Illustrates how to perform the same operation (addition) on MLX arrays using different devices (CPU and GPU) by specifying the 'stream' parameter. Data remains in unified memory, avoiding costly transfers between devices.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/Articles/unified-memory.md#_snippet_1

LANGUAGE: Swift
CODE:
```
add(a, b, stream: .cpu)
add(a, b, stream: .gpu)
```

----------------------------------------

TITLE: Convert Linear Layer from Python to Swift
DESCRIPTION: This snippet illustrates the conversion of a Linear layer, a fundamental neural network component, from Python to Swift. It covers the initialization of weights and an optional bias using random uniform distribution, and the forward pass involving matrix multiplication. Key differences include Swift's explicit `init` methods and optional types for bias, compared to Python's dynamic attribute assignment and `__call__` method.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLXNN/Documentation.docc/custom-layers.md#_snippet_11

LANGUAGE: Python
CODE:
```
class Linear(Module):
    def __init__(self, input_dims: int, output_dims: int, bias: bool = True) -> None:
        super().__init__()
        scale = math.sqrt(1.0 / input_dims)
        self.weight = mx.random.uniform(
            low=-scale,
            high=scale,
            shape=(output_dims, input_dims),
        )
        if bias:
            self.bias = mx.random.uniform(
                low=-scale,
                high=scale,
                shape=(output_dims,),
            )

    def _extra_repr(self) -> str:
        return f"input_dims={self.weight.shape[1]}, output_dims={self.weight.shape[0]}, bias={'bias' in self}"

    def __call__(self, x: mx.array) -> mx.array:
        x = x @ self.weight.T
        if "bias" in self:
            x = x + self.bias
        return x
```

LANGUAGE: Swift
CODE:
```
public class Linear: Module, UnaryLayer {

    let weight: MLXArray
    let bias: MLXArray?

    public init(_ inputDimensions: Int, _ outputDimensions: Int, bias: Bool = true) {
        let scale = sqrt(1.0 / Float(inputDimensions))
        self.weight = MLXRandom.uniform(-scale ..< scale, [outputDimensions, inputDimensions])
        if bias {
            self.bias = MLXRandom.uniform(-scale ..< scale, [outputDimensions])
        } else {
            self.bias = nil
        }
        super.init()
    }

    internal init(weight: MLXArray, bias: MLXArray? = nil) {
        self.weight = weight
        self.bias = bias
    }

    public override func describeExtra(_ indent: Int) -> String {
        "(inputDimensions=\(weight.dim(1)), outputDimensions=\(weight.dim(0)), bias=\(bias == nil ? "false" : "true"))"
    }

    public func callAsFunction(_ x: MLXArray) -> MLXArray {
        var result = x.matmul(weight.T)
        if let bias {
            result = result + bias
        }
        return result
    }
}
```

----------------------------------------

TITLE: Apply ModuleInfo to Linear Modules in Swift FeedForward
DESCRIPTION: This Swift code defines a `FeedForward` module where `Linear` sub-modules (`w1`, `w2`, `w3`) are annotated with `@ModuleInfo`. This annotation is essential as it provides a hook for `QuantizedLinear/quantize` and `Module/update` to replace these linear layers at runtime with compatible models, such as quantized versions.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLXNN/Documentation.docc/custom-layers.md#_snippet_9

LANGUAGE: Swift
CODE:
```
public class FeedForward : Module {

    @ModuleInfo var w1: Linear
    @ModuleInfo var w2: Linear
    @ModuleInfo var w3: Linear

    public init(_ args: Configuration) {
        self.w1 = Linear(args.dimensions, args.hiddenDimensions, bias: false)
        self.w2 = Linear(args.hiddenDimensions, args.dimensions, bias: false)
        self.w3 = Linear(args.dimensions, args.hiddenDimensions, bias: false)
    }
```

----------------------------------------

TITLE: Clone MLX Swift Repository with Submodules
DESCRIPTION: This command clones the `mlx-swift` repository and its essential git submodules simultaneously. Submodules are crucial for dependencies like the `Cmlx` library, which contains compiled Metal shaders.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/troubleshooting.md#_snippet_0

LANGUAGE: Shell
CODE:
```
git clone --recurse-submodules https://github.com/ml-explore/mlx-swift.git
```

----------------------------------------

TITLE: Add MLX Swift Package Dependencies for SwiftPM
DESCRIPTION: This snippet demonstrates how to configure your `Package.swift` file to include the MLX Swift package as a dependency for Swift Package Manager. It covers adding the main package URL and then linking specific products like `MLX`, `MLXNN`, and `MLXOptimizers`.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/README.md#_snippet_0

LANGUAGE: Swift
CODE:
```
dependencies: [
    .package(url: "https://github.com/ml-explore/mlx-swift", from: "0.10.0")
]
```

LANGUAGE: Swift
CODE:
```
dependencies: [.product(name: "MLX", package: "mlx-swift"),
               .product(name: "MLXNN", package: "mlx-swift"),
               .product(name: "MLXOptimizers", package: "mlx-swift")]
```

----------------------------------------

TITLE: Monitor MLX GPU Memory Usage in Swift
DESCRIPTION: This Swift code snippet illustrates how to monitor MLX GPU memory usage over time using `GPU.snapshot()`. It captures memory statistics before and after a workload, and then prints details about total memory limit, cache limit, starting memory, ending memory, and the growth (delta) between the two snapshots. This helps in debugging and optimizing memory consumption.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/Articles/running-on-ios.md#_snippet_1

LANGUAGE: Swift
CODE:
```
// load model & weights
...

let startMemory = GPU.snapshot()

// work
...

let endMemory = GPU.snapshot()

// what stats are interesting to you?

print("=======")
print("Memory size: \(GPU.memoryLimit / 1024)K")
print("Cache size:  \(GPU.cacheLimit / 1024)K")

print("")
print("=======")
print("Starting memory")
print(startMemory.description)

print("")
print("=======")
print("Ending memory")
print(endMemory.description)

print("")
print("=======")
print("Growth")
print(startMemory.delta(endMemory).description)
```

----------------------------------------

TITLE: Set MLX GPU Buffer Cache Limit in Swift
DESCRIPTION: This Swift code snippet demonstrates how to explicitly set the maximum size of the MLX GPU buffer cache. Limiting the cache can help control memory usage on iOS devices, preventing processes from being terminated by jetsam. The value is specified in bytes.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/Articles/running-on-ios.md#_snippet_0

LANGUAGE: Swift
CODE:
```
MLX.GPU.set(cacheLimit: 20 * 1024 * 1024)
```

----------------------------------------

TITLE: MLX Swift Vector, Matrix, and Tensor Product Functions
DESCRIPTION: Documents functions and methods in MLX Swift for performing various vector, matrix, and tensor product operations. This includes standard matrix multiplication, specialized masked and quantized multiplications, and generalized tensor contractions.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/Organization/arithmetic.md#_snippet_5

LANGUAGE: APIDOC
CODE:
```
MLXArray/matmul(_:stream:)
matmul(_:_:stream:)
gatherMatmul(_:_:lhsIndices:rhsIndices:stream:)
blockMaskedMM(_:_:blockSize:maskOut:maskLHS:maskRHS:stream:)
addMM(_:_:_:alpha:beta:stream:)
quantizedMatmul(_:_:scales:biases:transpose:groupSize:bits:stream:)
gatherQuantizedMatmul(_:_:scales:biases:lhsIndices:rhsIndices:transpose:groupSize:bits:stream:)
inner(_:_:stream:)
outer(_:_:stream:)
tensordot(_:_:axes:stream:)
tensordot(_:_:axes:stream:)
```

----------------------------------------

TITLE: MLX Swift vmap Function Reference
DESCRIPTION: Reference for the `vmap` function in MLX Swift, which transforms a function to operate independently over a batch axis. It allows specifying input and output axes for mapping, and supports nesting for multi-axis vectorization.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/Articles/vmap.md#_snippet_2

LANGUAGE: APIDOC
CODE:
```
vmap(_:inAxes:outAxes:)
  _ : The function to vectorize.
  inAxes: A tuple specifying which axis of each input to map over. Passing `nil` for an input disables mapping for that value.
  outAxes: A tuple specifying the axis of each output where the batched results are stacked.
```

----------------------------------------

TITLE: MLX Swift Element-wise Arithmetic Free Functions
DESCRIPTION: Lists free functions available in MLX Swift for performing element-wise arithmetic and logical operations on arrays and tensors. These functions typically take one or more MLXArray inputs and an optional stream parameter for execution control.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/Organization/arithmetic.md#_snippet_4

LANGUAGE: APIDOC
CODE:
```
abs(_:stream:)
acos(_:stream:)
acosh(_:stream:)
add(_:_:stream:)
asin(_:stream:)
asinh(_:stream:)
atan(_:stream:)
atan2(_:_:stream:)
atanh(_:stream:)
bitwiseAnd(_:_:stream:)
bitwiseOr(_:_:stream:)
bitwiseXOr(_:_:stream:)
ceil(_:stream:)
clip(_:min:max:stream:)
conjugate(_:stream:)
cos(_:stream:)
cosh(_:stream:)
degrees(_:stream:)
divide(_:_:stream:)
divmod(_:_:stream:)
erf(_:stream:)
erfInverse(_:stream:)
exp(_:stream:)
expm1(_:stream:)
floor(_:stream:)
floorDivide(_:_:stream:)
isNaN(_:stream:)
isInf(_:stream:)
isFinite(_:stream:)
isPosInf(_:stream:)
isNegInf(_:stream:)
leftShift(_:_:stream:)
log(_:stream:)
log10(_:stream:)
log1p(_:stream:)
log2(_:stream:)
logAddExp(_:_:stream:)
logicalAnd(_:_:stream:)
logicalNot(_:stream:)
logicalOr(_:_:stream:)
maximum(_:_:stream:)
minimum(_:_:stream:)
multiply(_:_:stream:)
nanToNum(_:nan:posInf:negInf:stream:)
negative(_:stream:)
notEqual(_:_:stream:)
pow(_:_:stream:)
pow(_:_:stream:)
pow(_:_:stream:)
radians(_:stream:)
reciprocal(_:stream:)
remainder(_:_:stream:)
rightShift(_:_:stream:)
round(_:decimals:stream:)
rsqrt(_:stream:)
sigmoid(_:stream:)
sign(_:stream:)
sin(_:stream:)
sinh(_:stream:)
softmax(_:axes:precise:stream:)
sqrt(_:stream:)
square(_:stream:)
subtract(_:_:stream:)
tan(_:stream:)
tanh(_:stream:)
trace(_:offset:axis1:axis2:dtype:stream:)
which(_:_:_:stream:)
```

----------------------------------------

TITLE: Avoiding Unnecessary Computations with Lazy Evaluation in MLX Swift
DESCRIPTION: This Swift function demonstrates how MLX's lazy evaluation prevents computation of unused outputs. Even if `expensiveFunction` is called, its result `b` is not computed if it's not used, though its graph is still built.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/Articles/lazy-evaluation.md#_snippet_0

LANGUAGE: swift
CODE:
```
func f(_ x: MLXArray) -> (MLXArray, MLXArray) {
    let a = fun1(x)
    let b = expensiveFunction(a)
    return (a, b)
}

let (y, _) = f(x)
```

----------------------------------------

TITLE: Optimizing Memory with Lazy Model Initialization in MLX Swift
DESCRIPTION: This Swift example illustrates how lazy evaluation in MLX allows for memory optimization during model initialization. Model weights are initialized lazily, enabling efficient updates (e.g., to `float16`) without consuming full memory until an explicit evaluation.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/Articles/lazy-evaluation.md#_snippet_1

LANGUAGE: swift
CODE:
```
let model = Model()

let url = URL(filePath: "weights_fp16.safetensors")
let weights = loadArrays(url: url)

model.update(parameters: weights)
```

----------------------------------------

TITLE: Optimal Evaluation Strategy in MLX Swift Iterative Loops
DESCRIPTION: This Swift code snippet demonstrates a recommended pattern for evaluating MLX compute graphs within an iterative loop, such as stochastic gradient descent. Evaluating at each outer loop iteration balances graph size overhead and batching useful work, ensuring efficiency.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/Articles/lazy-evaluation.md#_snippet_2

LANGUAGE: swift
CODE:
```
for batch in dataset {
    // Nothing has been evaluated yet
    let (loss, grad) = valueAndGrad(model, batch)

    // Still nothing has been evaluated
    optimizer.update(model, grad)

    // Evaluate the loss and the new parameters which will
    // run the full gradient computation and optimizer update
    eval(loss, model)
}
```

----------------------------------------

TITLE: Python mx.array to Swift MLXArray Method Mapping
DESCRIPTION: This API documentation provides a direct mapping between common `mx.array` methods in Python and their equivalent `MLXArray` methods in Swift. It helps developers understand how to translate operations between the two MLX language bindings.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/Articles/converting-python.md#_snippet_2

LANGUAGE: APIDOC
CODE:
```
Python: __init__ -> Swift: see <doc:initialization>
Python: __repr__ -> Swift: MLXArray/description
Python: __eq__ -> Swift: MLXArray/.==(_:_:)-56m0a
Python: size -> Swift: MLXArray/size
Python: ndim -> Swift: MLXArray/ndim
Python: itemsize -> Swift: MLXArray/itemSize
Python: nbytes -> Swift: MLXArray/nbytes
Python: shape -> Swift: MLXArray/shape or MLXArray/shape2 ... MLXArray/shape4 (destructuring)
Python: dtype -> Swift: MLXArray/dtype
Python: item -> Swift: MLXArray/item(_:)
Python: tolist -> Swift: MLXArray/asArray(_:)
Python: astype -> Swift: MLXArray/asType(_:stream:)-4eqoc or MLXArray/asType(_:stream:)-6d44y
Python: __getitem__ -> Swift: MLXArray/subscript(_:stream:)-375a0
Python: __len__ -> Swift: MLXArray/count
Python: __iter__ -> Swift: implements Sequence
Python: __add__ -> Swift: MLXArray/+(_:_:)-1rv98
Python: __iadd__ -> Swift: MLXArray/+=(_:_:)-3feg7
Python: __sub__ -> Swift: MLXArray/-(_:_:)-7frdo
Python: __isub__ -> Swift: MLXArray/-=(_:_:)-4d4ei
Python: __mul__ -> Swift: MLXArray/*(_:_:)-1z2ck
Python: __imul__ -> Swift: MLXArray/*=(_:_:)-9ukv3
Python: __truediv__ -> Swift: MLXArray//(_:_:)-6ijef
Python: __div__ -> Swift: MLXArray//(_:_:)-6ijef
Python: __idiv__ -> Swift: MLXArray//=(_:_:)-9egbn
Python: __floordiv__ -> Swift: MLXArray/floorDivide(_:stream:)
Python: __mod__ -> Swift: MLXArray/%(_:_:)-3ubwd
Python: __eq__ -> Swift: MLXArray/.==(_:_:)-56m0a
Python: __lt__ -> Swift: MLXArray/.<(_:_:)-9rzup
Python: __le__ -> Swift: MLXArray/.<=(_:_:)-2a0s9
Python: __gt__ -> Swift: MLXArray/.>(_:_:)-fwi1
Python: __ge__ -> Swift: MLXArray/.>=(_:_:)-2gqml
Python: __ne__ -> Swift: MLXArray/.!=(_:_:)-mbw0
Python: __neg__ -> Swift: MLXArray/-(_:)
Python: __bool__ -> Swift: MLXArray/all(keepDims:stream:) + MLXArray/item()
Python: __repr__ -> Swift: MLXArray/description
Python: __matmul__ -> Swift: MLXArray/matmul(_:stream:)
Python: __pow__ -> Swift: MLXArray/**(_:_:)-8xxt3
Python: abs -> Swift: MLXArray/abs(stream:)
Python: all -> Swift: MLXArray/all(axes:keepDims:stream:)
Python: any -> Swift: MLXArray/any(axes:keepDims:stream:)
Python: argmax -> Swift: MLXArray/argMax(axis:keepDims:stream:)
Python: argmin -> Swift: MLXArray/argMin(axis:keepDims:stream:)
Python: cos -> Swift: MLXArray/cos(stream:)
Python: cummax -> Swift: MLXArray/cummax(axis:reverse:inclusive:stream:)
Python: cummin -> Swift: MLXArray/cummin(axis:reverse:inclusive:stream:)
Python: cumprod -> Swift: MLXArray/cumprod(axis:reverse:inclusive:stream:)
Python: cumsum -> Swift: MLXArray/cumsum(axis:reverse:inclusive:stream:)
Python: exp -> Swift: MLXArray/exp(stream:)
Python: flatten -> Swift: MLXArray/flattened(start:end:stream:)
Python: log -> Swift: MLXArray/log(stream:)
Python: log10 -> Swift: MLXArray/log10(stream:)
Python: log1p -> Swift: MLXArray/log1p(stream:)
Python: log2 -> Swift: MLXArray/log2(stream:)
Python: logsumexp -> Swift: MLXArray/logSumExp(axes:keepDims:stream:)
Python: max -> Swift: MLXArray/max(axes:keepDims:stream:)
Python: mean -> Swift: MLXArray/mean(axes:keepDims:stream:)
Python: min -> Swift: MLXArray/min(axes:keepDims:stream:)
Python: moveaxis -> Swift: MLXArray/movedAxis(source:destination:stream:)
Python: prod -> Swift: MLXArray/product(axes:keepDims:stream:)
Python: reciprocal -> Swift: MLXArray/reciprocal(stream:)
Python: reshape -> Swift: MLXArray/reshaped(_:stream:)-67a89
Python: round -> Swift: MLXArray/round(decimals:stream:)
Python: rsqrt -> Swift: MLXArray/rsqrt(stream:)
Python: sin -> Swift: MLXArray/sin(stream:)
Python: split -> Swift: MLXArray/split(parts:axis:stream:) or MLXArray/split(axis:stream:) (destructuring)
Python: sqrt -> Swift: MLXArray/sqrt(stream:)
Python: square -> Swift: MLXArray/square(stream:)
Python: squeeze -> Swift: MLXArray/squeezed(axes:stream:)
Python: sum -> Swift: MLXArray/sum(axes:keepDims:stream:)
Python: swapaxes -> Swift: MLXArray/swappedAxes(_:_:stream:)
Python: T -> Swift: MLXArray/T
Python: transpose -> Swift: MLXArray/transposed(_:stream:)
Python: var -> Swift: MLXArray/variance(axes:keepDims:ddof:stream:)
```

----------------------------------------

TITLE: Define Gelu Activation Function in Swift MLX
DESCRIPTION: This snippet defines the `gelu` (Gaussian Error Linear Unit) activation function in Swift using MLXArray. It's a common nonlinear function used with Transformer-based models, implemented with several unary and binary element-wise operations.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/Articles/compilation.md#_snippet_1

LANGUAGE: Swift
CODE:
```
public func gelu(_ x: MLXArray) -> MLXArray {
    x * (1 + erf(x / sqrt(2))) / 2
}
```

----------------------------------------

TITLE: Controlling Input Axes with vmap in MLX Swift
DESCRIPTION: This example illustrates how to use the `inAxes` parameter with `vmap` to specify which input axes should be mapped over. By setting `inAxes` to `(0, nil)`, the first input (`x`) is mapped along its first axis while the second input (`y`) is used as a broadcast value.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/Articles/vmap.md#_snippet_1

LANGUAGE: Swift
CODE:
```
func add(_ x: MLXArray, _ y: MLXArray) -> MLXArray { x + y }
let vf = vmap(add, inAxes: (0, nil))
```

----------------------------------------

TITLE: Declare Custom MLXNN Module Subclass in Swift
DESCRIPTION: This Swift code defines a `FeedForward` neural network layer by subclassing `Module` and implementing `UnaryLayer`. It demonstrates declaring sub-modules with `@ModuleInfo`, initializing them in the constructor, and providing a `callAsFunction` for forward pass computation.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLXNN/Documentation.docc/custom-layers.md#_snippet_0

LANGUAGE: Swift
CODE:
```
// 1. Declare your class
// 2. Since this class takes a single MLXArray argument we can declare as UnaryLayer
public class FeedForward : Module, UnaryLayer {

    // 3. Declare your sub-modules and parameters as needed
    // 4. See section on ModuleInfo/ParameterInfo below
    @ModuleInfo var w1: Linear
    @ModuleInfo var w2: Linear
    @ModuleInfo var w3: Linear

    // 5. Initialize your ivars
    public init(dimensions: Int, hiddenDimensions: Int, outputDimensions: Int) {
        self.w1 = Linear(dimensions, hiddenDimensions, bias: false)
        self.w2 = Linear(hiddenDimensions, dimensions, bias: false)
        self.w3 = Linear(dimensions, outputDimensions, bias: false)
    }

    // 6. Provide the API to call it
    public func callAsFunction(_ x: MLXArray) -> MLXArray {
        w2(silu(w1(x)) * w3(x))
    }
}
```

----------------------------------------

TITLE: Basic Usage of MLX Compile Function in Swift
DESCRIPTION: This snippet demonstrates the basic usage of MLX's `compile` function in Swift. It defines a simple function `f` and shows how to call it both regularly and after compilation, illustrating that the output remains consistent. It also highlights that compilation is cached for subsequent calls.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/Articles/compilation.md#_snippet_0

LANGUAGE: Swift
CODE:
```
func f(_ x: MLXArray, _ y: MLXArray) -> MLXArray {
    exp(-x) + y
}

let x = MLXArray(1.0)
let y = MLXArray(2.0)

// regular function call, prints array(2.36788, dtype=float32)
print(f(x, y))

// compile the function
let compiled = compile(f)

// call the compiled version, prints array(2.36788, dtype=float32)
print(compiled(x, y))
```

----------------------------------------

TITLE: MLXArray Advanced Indexing with Another MLXArray in Swift
DESCRIPTION: This snippet demonstrates advanced indexing in MLXArray using another MLXArray as indices, similar to NumPy's integer array indexing. It shows how to sort an array by using argSort to get the sort indices and then applying these indices to the original array to obtain a sorted version.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/Organization/indexing.md#_snippet_2

LANGUAGE: Swift
CODE:
```
// array with values in random order
let array = MLXRandom.randInt(0 ..< 100, [10])

let sortIndexes = argSort(array, axis: -1)

// the array in sorted order
let sorted = array[sortIndexes]
```

----------------------------------------

TITLE: MLX Swift Indexing Free Functions
DESCRIPTION: Details free functions in MLX Swift for array indexing and manipulation, including argument maximum/minimum, partitioning, sorting, and taking elements.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/free-functions.md#_snippet_3

LANGUAGE: APIDOC
CODE:
```
argMax(_:axis:keepDims:stream:)
argMax(_:keepDims:stream:)
argMin(_:axis:keepDims:stream:)
argMin(_:keepDims:stream:)
argPartition(_:kth:axis:stream:)
argPartition(_:kth:stream:)
argSort(_:axis:stream:)
argSort(_:stream:)
takeAlong(_:_:axis:stream:)
takeAlong(_:_:stream:)
take(_:_:stream:)
take(_:_:axis:stream:)
top(_:k:stream:)
top(_:k:axis:stream:)
```

----------------------------------------

TITLE: MLXNN Core Functions API Reference (Activations, Losses, ValueAndGrad)
DESCRIPTION: Detailed API for activation functions (both free and module-based), various loss functions, and the valueAndGrad utility for gradient computation in MLXNN.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLXNN/Documentation.docc/MLXNN.md#_snippet_2

LANGUAGE: APIDOC
CODE:
```
Activation Free Functions:
  - celu(_:alpha:)
  - elu(_:alpha:)
  - gelu(_:)
  - geluApproximate(_:)
  - geluFastApproximate(_:)
  - glu(_:axis:)
  - hardSwish(_:)
  - leakyRelu(_:negativeSlope:)
  - logSigmoid(_:)
  - logSoftmax(_:axis:)
  - mish(_:)
  - prelu(_:alpha:)
  - relu(_:)
  - relu6(_:)
  - selu(_:)
  - silu(_:)
  - sigmoid(_:)
  - softplus(_:)
  - softsign(_:)
  - step(_:threshold:)

Activation Modules:
  - CELU
  - GELU
  - GLU
  - HardSwish
  - LeakyReLU
  - LogSigmoid
  - LogSoftmax
  - Mish
  - PReLU
  - ReLU
  - ReLU6
  - SELU
  - SiLU
  - Sigmoid
  - Softmax
  - Softplus
  - Softsign
  - Step
  - Tanh

Loss Functions:
  - binaryCrossEntropy(logits:targets:weights:withLogits:reduction:)
  - cosineSimilarityLoss(x1:x2:axis:eps:reduction:)
  - crossEntropy(logits:targets:weights:axis:labelSmoothing:reduction:)
  - hingeLoss(inputs:targets:reduction:)
  - huberLoss(inputs:targets:delta:reduction:)
  - klDivLoss(inputs:targets:axis:reduction:)
  - l1Loss(predictions:targets:reduction:)
  - logCoshLoss(inputs:targets:reduction:)
  - mseLoss(predictions:targets:reduction:)
  - nllLoss(inputs:targets:axis:reduction:)
  - smoothL1Loss(predictions:targets:beta:reduction:)
  - tripletLoss(anchors:positives:negatives:axis:p:margin:eps:reduction:)

Value and Grad Functions:
  - valueAndGrad(model:_:)-12a2c
  - valueAndGrad(model:_:)-548r7
  - valueAndGrad(model:_:)-45dg5
```

----------------------------------------

TITLE: Managing Dependencies Across Devices (Swift)
DESCRIPTION: Shows how MLX automatically manages dependencies between operations running on different devices. The MLX scheduler ensures that a dependent operation on one device (e.g., GPU) waits for its prerequisite operation on another device (e.g., CPU) to complete.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/Articles/unified-memory.md#_snippet_2

LANGUAGE: Swift
CODE:
```
let c = add(a, b, stream: .cpu)
let d = add(a, c, stream: .gpu)
```

----------------------------------------

TITLE: MLXNN Layer Types and Base Components API Reference
DESCRIPTION: Comprehensive documentation for various layer types and foundational components in MLXNN, including base classes, unary layers, recurrent layers, and specialized layers for normalization, positional encoding, and transformers.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLXNN/Documentation.docc/MLXNN.md#_snippet_1

LANGUAGE: APIDOC
CODE:
```
Base Classes and Interfaces:
  - Module
  - UnaryLayer
  - Quantizable
  - ModuleInfo
  - ParameterInfo
  - ModuleParameters
  - ModuleChildren
  - ModuleItem
  - ModuleItems
  - ModuleValue

Unary Layers (for Sequential):
  - AvgPool1d
  - AvgPool2d
  - Conv1d
  - Conv2d
  - Dropout
  - Dropout2d
  - Dropout3d
  - Embedding
  - Identity
  - Linear
  - MaxPool1d
  - MaxPool2d
  - QuantizedLinear
  - RoPE
  - RMSNorm
  - Sequential

Sampling Layers:
  - Upsample

Recurrent Layers:
  - RNN
  - GRU
  - LSTM

Other Layers:
  - Bilinear
  - MultiHeadAttention

Normalization Layers:
  - InstanceNorm
  - LayerNorm
  - RMSNorm
  - GroupNorm
  - BatchNorm

Positional Encoding Layers:
  - RoPE
  - SinusoidalPositionalEncoding
  - ALiBi

Transformer Layers:
  - MultiHeadAttention
  - Transformer
```

----------------------------------------

TITLE: Apply Element-wise Math Functions to MLXArray in Swift
DESCRIPTION: Illustrates the application of an element-wise mathematical function, 'log', to an MLXArray. This example shows how such functions operate on each element of the array independently.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/Organization/arithmetic.md#_snippet_1

LANGUAGE: Swift
CODE:
```
let a = MLXArray(0 ..< 12, [4, 3])

let r = log(a)
```

----------------------------------------

TITLE: Run Pre-commit Hooks for MLX Swift Project
DESCRIPTION: Command to execute all pre-commit hooks across the project files to ensure code quality and formatting before committing changes.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/MAINTENANCE.md#_snippet_7

LANGUAGE: Shell
CODE:
```
pre-commit run --all-files
```

----------------------------------------

TITLE: MLX Swift: Pure Functions and Side Effects
DESCRIPTION: Compiled functions in MLX Swift are designed to be pure, meaning they should not produce side effects. This example demonstrates how modifying an external variable within a compiled function can lead to a runtime crash when the resulting placeholder array is accessed.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/Articles/compilation.md#_snippet_5

LANGUAGE: swift
CODE:
```
var state = [MLXArray]()

func f(_ x: MLXArray) -> MLXArray {
    let z = x * 8
    state.append(z)
    return exp(z)
}

let compiled = compile(f)
_ = compiled(MLXArray(1.0))

// this will crash
print(state)
```

----------------------------------------

TITLE: MLXArray Shape Manipulation (Same Element Count)
DESCRIPTION: Methods that modify the shape of an MLXArray without changing the total number of elements or the array's underlying contents.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/Organization/shapes.md#_snippet_1

LANGUAGE: APIDOC
CODE:
```
MLXArray/expandedDimensions(axis:stream:)
MLXArray/expandedDimensions(axes:stream:)
MLXArray/flattened(start:end:stream:)
MLXArray/reshaped(_:stream:)-19x5z
MLXArray/reshaped(_:stream:)-67a89
MLXArray/squeezed(stream:)
MLXArray/squeezed(axis:stream:)
MLXArray/squeezed(axes:stream:)
expandedDimensions(_:axis:stream:)
expandedDimensions(_:axes:stream:)
asStrided(_:_:strides:offset:stream:)
atLeast1D(_:stream:)
atLeast2D(_:stream:)
atLeast3D(_:stream:)
flattened(_:start:end:stream:)
reshaped(_:_:stream:)-5x3y0
squeezed(_:axes:stream:)
roll(_:shift:axis:stream:)
roll(_:shift:axes:stream:)
```

----------------------------------------

TITLE: Apply Array Broadcasting with Compatible Shapes in MLX
DESCRIPTION: Illustrates broadcasting between two MLXArrays with different but compatible shapes. It highlights the rules for compatibility (equal dimensions, or one dimension is 1 or missing) and how the resulting array's shape is determined by the maximum of the two matching dimensions.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/Articles/broadcasting.md#_snippet_2

LANGUAGE: Swift
CODE:
```
let a = MLXArray(0 ..< 12, [4, 3])
let b = MLXArray(0 ..< 3, [3])

// compatible because the last dimensions match:
// [4, 3]
// [   3]
let r = a + b
```

----------------------------------------

TITLE: Demonstrate MLXArray Memory Safety Issue in Swift
DESCRIPTION: This Swift code snippet highlights a memory safety concern with MLXArray. Unlike Swift's native `Array`, MLXArray does not enforce memory safety for indexing operations. Accessing an out-of-bounds index, such as `a[10000]` for an array with a single element, will not result in a runtime error but will instead print a random value from outside the array's allocated memory, indicating potential data corruption or unexpected behavior.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/MLXArray.md#_snippet_2

LANGUAGE: swift
CODE:
```
let a = MLXArray([0])
print(a[10000])
```

----------------------------------------

TITLE: Example Function Utilizing Mixed-Device Operations (Swift)
DESCRIPTION: Defines a function 'f' that performs a matrix multiplication (potentially on GPU) and a series of element-wise exponentiations (potentially on CPU). This demonstrates a scenario where different parts of a computation are optimally run on different devices using unified memory for performance gains.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/Articles/unified-memory.md#_snippet_3

LANGUAGE: Swift
CODE:
```
func f(a: MLXArray, b: MLXArray, d1: StreamOrDevice, d2: StreamOrDevice) -> (MLXArray, MLXArray) {
    let x = matmul(a, b, stream: d1)
    var b = b
    for _ in 0 ..< 500 {
        b = exp(b, stream: d2)
    }
    return (x, b)
}
```

----------------------------------------

TITLE: MLX Swift: Defining Model and Loss for Training Graph Compilation
DESCRIPTION: This snippet sets up the foundational components for compiling a training graph in MLX Swift. It defines a simple `LinearFunctionModel` conforming to `Module` and `UnaryLayer`, a `loss` function using `mseLoss`, and an `SGD` optimizer, preparing the environment for a training loop.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/Articles/compilation.md#_snippet_10

LANGUAGE: swift
CODE:
```
class LinearFunctionModel: Module, UnaryLayer {
    let m = MLXRandom.uniform(low: -5.0, high: 5.0)
    let b = MLXRandom.uniform(low: -5.0, high: 5.0)

    func callAsFunction(_ x: MLXArray) -> MLXArray {
        m * x + b
    }
}

func loss(model: LinearFunctionModel, x: MLXArray, y: MLXArray) -> MLXArray {
    mseLoss(predictions: model(x), targets: y, reduction: .mean)
}

let model = LinearFunctionModel()
eval(model)

let lg = valueAndGrad(model: model, loss)

// the optimizer will use the gradients update the model parameters
let optimizer = SGD(learningRate: 1e-1)

// these are the target parameters
let m = 0.25
let b = 7
```

----------------------------------------

TITLE: MLXArray Slicing with Swift Range Expressions
DESCRIPTION: This snippet details various slicing techniques in MLXArray using Swift's RangeExpression syntax. It covers standard range slices, open-ended ranges, full range slices, closed ranges, and slices with explicit strides, including negative strides for reversing axes.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/Organization/indexing.md#_snippet_4

LANGUAGE: Swift
CODE:
```
// python: array[1:5]
array[1 ..< 5]
```

LANGUAGE: Swift
CODE:
```
// python: array[:5]
array[..<5]

// python: array[3:]
array[3..<]
```

LANGUAGE: Swift
CODE:
```
// python: array[:]
array[0...]
```

LANGUAGE: Swift
CODE:
```
// no python equivalent
array[1 ... 4]
```

LANGUAGE: Swift
CODE:
```
// full range, stride by 2
// python: array[::2]
array[.stride(by: 2)]

// start/end, stride by 2
// python: array[1:6:2]
array[.stride(from: 1, to: 6, by: 2)]
```

LANGUAGE: Swift
CODE:
```
// reverse the axis
// python: array[::-1]
array[.stride(by: -1)]
```

----------------------------------------

TITLE: Instantiate and Use Custom MLXNN FeedForward Layer in Swift
DESCRIPTION: This Swift example demonstrates how to instantiate the previously defined `FeedForward` layer with specific dimensions. It then shows how to pass an `MLXArray` input to the layer, implicitly calling its `callAsFunction` method to get the output.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLXNN/Documentation.docc/custom-layers.md#_snippet_1

LANGUAGE: Swift
CODE:
```
let layer = FeedForward(dimensions: 20, hiddenDimensions: 64, outputDimensions: 20)

let input: MLXArray

// this calls the `callAsFunction()`
let output = layer(input)
```

----------------------------------------

TITLE: Use MLXArray Logical Operators for Control Flow in Swift
DESCRIPTION: Illustrates how the results of MLXArray logical operations can be used for control flow, such as in an 'if' statement. It's important to consider lazy evaluation when using this pattern.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/Organization/logical.md#_snippet_1

LANGUAGE: Swift
CODE:
```
if (a < b).all().item() {
    ...
}
```

----------------------------------------

TITLE: Reading MLXArray Shapes
DESCRIPTION: Methods for querying the dimensions and shape of an MLXArray without modifying its contents.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/Organization/shapes.md#_snippet_0

LANGUAGE: APIDOC
CODE:
```
MLXArray/shape
MLXArray/shape2
MLXArray/shape3
MLXArray/shape4
MLXArray/dim(_:)
```

----------------------------------------

TITLE: Perform Scalar Addition with MLXArray Broadcasting
DESCRIPTION: Demonstrates adding a scalar value to every element of an MLXArray. MLX Swift's `ScalarOrArray` mechanism automatically converts the scalar, enabling efficient broadcasting without explicit array expansion.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/Articles/broadcasting.md#_snippet_1

LANGUAGE: Swift
CODE:
```
let r = array + 1
```

----------------------------------------

TITLE: Configure and Install fmt Library Targets with CMake
DESCRIPTION: This CMake snippet defines and configures the installation targets for the 'fmt' library. It sets up installation directories for CMake files, libraries, and pkgconfig files, generates package configuration and version files, and installs the library, headers, and associated CMake exports. It ensures proper namespace usage for imported targets.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/CMakeLists.txt#_snippet_23

LANGUAGE: CMake
CODE:
```
if(FMT_INSTALL)
  include(CMakePackageConfigHelpers)
  set_verbose(
    FMT_CMAKE_DIR
    ${CMAKE_INSTALL_LIBDIR}/cmake/fmt
    CACHE
    STRING
    "Installation directory for cmake files, a relative path that "
    "will be joined with ${CMAKE_INSTALL_PREFIX} or an absolute "
    "path.")
  set(version_config ${PROJECT_BINARY_DIR}/fmt-config-version.cmake)
  set(project_config ${PROJECT_BINARY_DIR}/fmt-config.cmake)
  set(pkgconfig ${PROJECT_BINARY_DIR}/fmt.pc)
  set(targets_export_name fmt-targets)

  set_verbose(
    FMT_LIB_DIR ${CMAKE_INSTALL_LIBDIR} CACHE STRING
    "Installation directory for libraries, a relative path that "
    "will be joined to ${CMAKE_INSTALL_PREFIX} or an absolute path.")

  set_verbose(
    FMT_PKGCONFIG_DIR
    ${CMAKE_INSTALL_LIBDIR}/pkgconfig
    CACHE
    STRING
    "Installation directory for pkgconfig (.pc) files, a relative "
    "path that will be joined with ${CMAKE_INSTALL_PREFIX} or an "
    "absolute path.")

  # Generate the version, config and target files into the build directory.
  write_basic_package_version_file(
    ${version_config}
    VERSION ${FMT_VERSION}
    COMPATIBILITY AnyNewerVersion)

  join_paths(libdir_for_pc_file "\${exec_prefix}" "${FMT_LIB_DIR}")
  join_paths(includedir_for_pc_file "\${prefix}" "${FMT_INC_DIR}")

  configure_file("${PROJECT_SOURCE_DIR}/support/cmake/fmt.pc.in" "${pkgconfig}"
                 @ONLY)
  configure_package_config_file(
    ${PROJECT_SOURCE_DIR}/support/cmake/fmt-config.cmake.in ${project_config}
    INSTALL_DESTINATION ${FMT_CMAKE_DIR})

  set(INSTALL_TARGETS fmt fmt-header-only)

  # Install the library and headers.
  install(
    TARGETS ${INSTALL_TARGETS}
    EXPORT ${targets_export_name}
    LIBRARY DESTINATION ${FMT_LIB_DIR}
    ARCHIVE DESTINATION ${FMT_LIB_DIR}
    PUBLIC_HEADER DESTINATION "${FMT_INC_DIR}/fmt"
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})

  # Use a namespace because CMake provides better diagnostics for namespaced
  # imported targets.
  export(
    TARGETS ${INSTALL_TARGETS}
    NAMESPACE fmt::
    FILE ${PROJECT_BINARY_DIR}/${targets_export_name}.cmake)

  # Install version, config and target files.
  install(FILES ${project_config} ${version_config}
          DESTINATION ${FMT_CMAKE_DIR})
  install(
    EXPORT ${targets_export_name}
    DESTINATION ${FMT_CMAKE_DIR}
    NAMESPACE fmt::)

  install(FILES "${pkgconfig}" DESTINATION "${FMT_PKGCONFIG_DIR}")
endif()
```

----------------------------------------

TITLE: MLXArray Indexing for Set Operations in Swift
DESCRIPTION: This snippet illustrates how MLXArray indexing can be used to update array elements. It shows direct assignment to an indexed position and demonstrates how broadcasting applies when assigning a value to a slice, setting a larger area of the array.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/Organization/indexing.md#_snippet_1

LANGUAGE: Swift
CODE:
```
let array = MLXArray(0 ..< 512, [8, 8, 8])

let a2 = array[5]
array[5] = MLXArray(100)
```

LANGUAGE: Swift
CODE:
```
var a = MLXArray(0 ..< 512, [8, 8, 8])

// sets an [8, 8] area to 7 (broadcasting)
a[1] = MLXArray(7)
```

----------------------------------------

TITLE: Illustrate MLXArray Lazy Evaluation in Swift
DESCRIPTION: This Swift snippet illustrates the lazy evaluation nature of MLXArray. When `c = a + b` is executed, `c` does not immediately hold the result of the addition. Instead, it represents a computation graph that includes `a`, `b`, and the addition operation. This design choice makes MLXArray not thread-safe, as the graph should not be created in one thread and consumed in another.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/MLXArray.md#_snippet_1

LANGUAGE: swift
CODE:
```
let a: MLXArray
let b: MLXArray

let c = a + b
```

----------------------------------------

TITLE: Install Build Tools and Build MLX Swift with CMake
DESCRIPTION: This snippet provides the necessary shell commands to install CMake and Ninja using Homebrew, which are prerequisites for building MLX Swift with CMake. It then outlines the steps to configure, build, and run an example project using CMake and Ninja.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/README.md#_snippet_2

LANGUAGE: Shell
CODE:
```
brew install cmake
brew install ninja
```

LANGUAGE: Shell
CODE:
```
mkdir build
cd build
cmake .. -G Ninja
ninja
./example
```

----------------------------------------

TITLE: Format a string with fmt::format (C++)
DESCRIPTION: Shows how to format a string by embedding a value into a placeholder using `fmt::format`. The result is assigned to a `std::string`.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/README.md#_snippet_1

LANGUAGE: C++
CODE:
```
std::string s = fmt::format("The answer is {}.", 42);
// s == "The answer is 42."
```

----------------------------------------

TITLE: Define TransformerBlock Module in Python
DESCRIPTION: This Python code defines a `TransformerBlock` module, inheriting from `nn.Module`. It initializes various sub-modules like `Attention`, `FeedForward`, and `RMSNorm`, demonstrating a common structure for neural network layers in Python-based MLX examples. The instance variable names in this definition often necessitate replacement keys when porting to Swift.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLXNN/Documentation.docc/custom-layers.md#_snippet_7

LANGUAGE: Python
CODE:
```
class TransformerBlock(nn.Module):
    def __init__(self, args: ModelArgs):
        super().__init__()
        self.n_heads = args.n_heads
        self.dim = args.dim
        self.attention = Attention(args)
        self.feed_forward = FeedForward(args=args)
        self.attention_norm = RMSNorm(args.dim, eps=args.norm_eps)
        self.ffn_norm = RMSNorm(args.dim, eps=args.norm_eps)
        self.args = args
```

----------------------------------------

TITLE: MLXArray Logical Reduction Functions API Reference
DESCRIPTION: API documentation for logical reduction methods available on `MLXArray`, including `all` and `any` with various axis and dimension-keeping options.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/Organization/reduction.md#_snippet_1

LANGUAGE: APIDOC
CODE:
```
MLXArray methods:
- all(keepDims:stream:)
- all(axis:keepDims:stream:)
- all(axes:keepDims:stream:)
- any(keepDims:stream:)
- any(axis:keepDims:stream:)
- any(axes:keepDims:stream:)
```

----------------------------------------

TITLE: Module Training Control API
DESCRIPTION: API documentation for methods controlling the training state of a Module, including freezing, unfreezing, and setting the training mode.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLXNN/Documentation.docc/Module.md#_snippet_4

LANGUAGE: APIDOC
CODE:
```
Module Training API:
- freeze(recursive:keys:)
- freeze(recursive:keys:strict:)
- train(_:)
- unfreeze(recursive:keys:)
- unfreeze(recursive:keys:strict:)
```

----------------------------------------

TITLE: MLX Swift: compile Function Overloads
DESCRIPTION: This section documents the various overloads of the `compile` function in MLX Swift. These functions are crucial for optimizing computation graphs by allowing explicit control over inputs, outputs, and handling of shapeless arrays during compilation.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/Articles/compilation.md#_snippet_13

LANGUAGE: APIDOC
CODE:
```
compile(inputs:outputs:shapeless:_:)-8wq3u
compile(inputs:outputs:shapeless:_:)-15bpz
compile(inputs:outputs:shapeless:_:)-47dv3
compile(enable:)
```

----------------------------------------

TITLE: Add MLX Swift Package Dependency to Package.swift
DESCRIPTION: This snippet shows how to add the MLX Swift library as a package dependency in your 'Package.swift' file for use with Swift Package Manager. It specifies the GitHub URL and a minimum version.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/install.md#_snippet_0

LANGUAGE: Swift
CODE:
```
dependencies: [
    .package(url: "https://github.com/ml-explore/mlx-swift", from: "0.10.0")
]
```

----------------------------------------

TITLE: Manage Memory with C++ NS::SharedPtr
DESCRIPTION: This snippet illustrates memory management using `NS::SharedPtr` in C++. It initializes a shared pointer for `NS::AutoreleasePool` and creates an `NS::String`, demonstrating an alternative to manual pool release by leveraging smart pointers.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/metal-cpp/README.md#_snippet_10

LANGUAGE: C++
CODE:
```
NS::SharedPtr< NS::AutoreleasePool > pPool   = NS::TransferPtr( NS::AutoreleasePool::alloc()->init() );
NS::String*                          pString = NS::String::string( "Hello World", NS::ASCIIStringEncoding );

printf( "pString = \"%s\"\n", pString->cString( NS::ASCIIStringEncoding ) );
```

----------------------------------------

TITLE: Handle Int vs Int32 vs Int64 for MLXArray Initialization in Swift
DESCRIPTION: Explains the difference between Swift's 64-bit Int and MLX's preferred 32-bit integer type. Shows how to explicitly create Int32 and Int64 MLXArrays and the default behavior for Int literals.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/Organization/initialization.md#_snippet_2

LANGUAGE: Swift
CODE:
```
let i = Int32(10)
```

LANGUAGE: Swift
CODE:
```
let a = MLXArray(Int32(10))
```

LANGUAGE: Swift
CODE:
```
// also int32!
let a = MLXArray(10)
```

LANGUAGE: Swift
CODE:
```
// array creation with Int -- we want it to produce .int32
let a1 = MLXArray(500)
XCTAssertEqual(a1.dtype, .int32)

// eplicit int64
let a2 = MLXArray(int64: 500)
XCTAssertEqual(a2.dtype, .int64)
```

----------------------------------------

TITLE: MLX Swift: Handling State by Returning Outputs
DESCRIPTION: One approach to manage side effects in compiled functions is to return the updated state as part of the function's output. This allows the external state to be explicitly captured and used, preventing crashes associated with placeholder arrays.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/Articles/compilation.md#_snippet_6

LANGUAGE: swift
CODE:
```
var state = [MLXArray]()

func f(_ x: MLXArray) -> [MLXArray] {
    let z = x * 8
    state.append(z)
    return [exp(z), state]
}

// note: the arguments would have to be adapted -- using this form
// for example purposes only
let compiled = compile(f)
_ = compiled(MLXArray(1.0))

print(state)
```

----------------------------------------

TITLE: Example C++ application using fmt library
DESCRIPTION: A minimal C++ example demonstrating how to include and use the {fmt} library to print a formatted string to the console. This file is part of a larger Bazel project setup.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/support/bazel/README.md#_snippet_0

LANGUAGE: C++
CODE:
```
#include "fmt/core.h"

int main() {
  fmt::print("The answer is {}\n", 42);
}
```

----------------------------------------

TITLE: MLX Swift Device Management Functions
DESCRIPTION: This section documents the function for managing the device context in MLX Swift. The `using` function allows specifying the device (e.g., CPU, GPU) for a block of MLX operations.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/free-functions.md#_snippet_13

LANGUAGE: APIDOC
CODE:
```
- ``using(device:fn:)``
```

----------------------------------------

TITLE: Execute Code Block on Specific Device with using(device:fn:)
DESCRIPTION: Illustrates how to execute an entire block of Swift code on a specific device (e.g., GPU) using the `using(device:fn:)` function. All operations within the closure will be run on the specified device.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/Articles/using-streams.md#_snippet_1

LANGUAGE: swift
CODE:
```
using(device: .gpu) {
    // this code will run on gpu
    let a = MLXRandom.uniform([100, 100])
    let b = MLXRandom.uniform([100, 100])
}
```

----------------------------------------

TITLE: MLX Convolution Functions API Reference
DESCRIPTION: This section provides an API reference for the convolution functions available in MLX. It lists various convolution operations, including standard and transposed convolutions across different dimensions (1D, 2D, 3D), and general convolution utilities with detailed parameter options.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/Organization/convolution.md#_snippet_0

LANGUAGE: APIDOC
CODE:
```
MLX Convolution Functions:
- conv1d(_:_:stride:padding:dilation:groups:stream:)
- conv2d(_:_:stride:padding:dilation:groups:stream:)
- conv3d(_:_:stride:padding:dilation:groups:stream:)
- convGeneral(_:_:strides:padding:kernelDilation:inputDilation:groups:flip:stream:)-9t1sj
- convGeneral(_:_:strides:padding:kernelDilation:inputDilation:groups:flip:stream:)-6j1nr
- convTransposed1d(_:_:stride:padding:dilation:groups:stream:)
- convTransposed2d(_:_:stride:padding:dilation:groups:stream:)
- convTransposed3d(_:_:stride:padding:dilation:groups:stream:)
- convolve(_:_:mode:stream:)
```

----------------------------------------

TITLE: Sorting MLXArray Elements with argSort in Swift
DESCRIPTION: This Swift example demonstrates how to use `argSort` to obtain the indices that would sort an `MLXArray`. It initializes a random integer array, applies `argSort` to get the sorting permutation, and then uses these indices with array subscripting to produce the sorted version of the original array.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/Organization/indexes.md#_snippet_0

LANGUAGE: Swift
CODE:
```
// array with values in random order
let array = MLXRandom.randInt(0 ..< 100, [10])

let sortIndexes = argSort(array, axis: -1)

// the array in sorted order
let sorted = array[sortIndexes]
```

----------------------------------------

TITLE: Run MLX Swift Command Line Example with mlx-run
DESCRIPTION: This command demonstrates how to use the `mlx-run` wrapper script from `mlx-swift-examples` to execute a command-line tool, such as `llm-tool`. This script correctly sets the `DYLD_FRAMEWORK_PATH` to allow command-line tools to find required Metal shaders.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/troubleshooting.md#_snippet_2

LANGUAGE: Shell
CODE:
```
./mlx-run llm-tool --help
```

----------------------------------------

TITLE: Registering fmt Library Tests with CMake
DESCRIPTION: This section demonstrates the usage of the `add_fmt_test` function to register various test executables for the `fmt` library. It includes standard tests, tests with additional source files (e.g., `format-test mock-allocator.h`), and conditional tests based on compiler (MSVC) or build configurations (e.g., `format-impl-test HEADER_ONLY`, `compile-fp-test` with `/Zc:__cplusplus`). It also shows how to link against specific libraries or define preprocessor macros based on feature checks (e.g., `HAVE_STRPTIME`, `STDLIBFS`).
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/test/CMakeLists.txt#_snippet_3

LANGUAGE: CMake
CODE:
```
if(FMT_MODULE)
  return()
endif()

add_fmt_test(args-test)
add_fmt_test(assert-test)
add_fmt_test(chrono-test)
add_fmt_test(color-test)
add_fmt_test(core-test)
add_fmt_test(gtest-extra-test)
add_fmt_test(format-test mock-allocator.h)
if(MSVC)
  target_compile_options(format-test PRIVATE /bigobj)
endif()
if(NOT (MSVC AND BUILD_SHARED_LIBS))
  add_fmt_test(format-impl-test HEADER_ONLY header-only-test.cc)
endif()
add_fmt_test(ostream-test)
add_fmt_test(compile-test)
add_fmt_test(compile-fp-test HEADER_ONLY)
if(MSVC)
  # Without this option, MSVC returns 199711L for the __cplusplus macro.
  target_compile_options(compile-fp-test PRIVATE /Zc:__cplusplus)
endif()
add_fmt_test(printf-test)
add_fmt_test(ranges-test ranges-odr-test.cc)

add_fmt_test(scan-test)
check_symbol_exists(strptime "time.h" HAVE_STRPTIME)
if(HAVE_STRPTIME)
  target_compile_definitions(scan-test PRIVATE FMT_HAVE_STRPTIME)
endif()

add_fmt_test(std-test)
try_compile(compile_result_unused ${CMAKE_CURRENT_BINARY_DIR} SOURCES
            ${CMAKE_CURRENT_LIST_DIR}/detect-stdfs.cc OUTPUT_VARIABLE RAWOUTPUT)
string(REGEX REPLACE ".*libfound \"([^\"]*)\".*" "\\1" STDLIBFS "${RAWOUTPUT}")
if(STDLIBFS)
  target_link_libraries(std-test ${STDLIBFS})
endif()
add_fmt_test(unicode-test HEADER_ONLY)
if(MSVC)
  target_compile_options(unicode-test PRIVATE /utf-8)
endif()
add_fmt_test(xchar-test)
add_fmt_test(enforce-checks-test)
target_compile_definitions(enforce-checks-test
                           PRIVATE -DFMT_ENFORCE_COMPILE_STRING)
```

----------------------------------------

TITLE: Combine MLXArray with Logical Operators in Swift
DESCRIPTION: Demonstrates how single or multiple MLXArray instances can be combined using logical operators like greater than, less than, logical OR, and logical NOT.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/Organization/logical.md#_snippet_0

LANGUAGE: Swift
CODE:
```
let r = a > b || !(b < c)
```

----------------------------------------

TITLE: MLXArray Negative Indexing and Slicing in Swift
DESCRIPTION: This snippet illustrates how MLXArray supports negative indexing, similar to Python, for accessing elements from the end of an array or dimension. It covers single negative indices, negative indices in range expressions, and open-ended negative slices.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/Organization/indexing.md#_snippet_3

LANGUAGE: Swift
CODE:
```
// Reads the last element of the first axis
array[-1]

// Reads the last dimension of the array's shape
array.dim(-1)

// Iterates from the third-to-last index up to the last index
array[-3 ..< -1]

// Open-ended expression from third-to-last
array[(-3)...]
```

----------------------------------------

TITLE: Create Multi-Value MLXArrays from Collections in Swift
DESCRIPTION: Illustrates how to initialize MLXArray instances from Swift Arrays, Sequences, Data, or UnsafePointers, including controlling the shape of the resulting array.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/Organization/initialization.md#_snippet_4

LANGUAGE: Swift
CODE:
```
// create an array of Int64 with shape [3]
let v1 = MLXArray([1, 2, 3])
```

LANGUAGE: Swift
CODE:
```
// create an array of shape [12] from a sequence
let v1 = MLXArray(0 ..< 12)

// this works with various types of sequences
let v2 = MLXArray(stride(from: Float(0.5), to: Float(1.5), by: Float(0.1)))
```

LANGUAGE: Swift
CODE:
```
let data = Data([1, 2, 3, 4])

// directly from Data
let v1 = MLXArray(data, type: UInt8.self)

// or via a pointer
let v2 = data.withUnsafeBytes { ptr in
    MLXArray(ptr, type: UInt8.self)
}
```

LANGUAGE: Swift
CODE:
```
let v1 = MLXArray(0 ..< 12, [3, 4])
```

----------------------------------------

TITLE: Format a string with positional arguments using fmt::format (C++)
DESCRIPTION: Illustrates the use of positional arguments in `fmt::format` to control the order of inserted values within a format string. This allows for flexible string construction.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/README.md#_snippet_2

LANGUAGE: C++
CODE:
```
std::string s = fmt::format("I'd rather be {1} than {0}.", "right", "happy");
// s == "I'd rather be happy than right."
```

----------------------------------------

TITLE: MLXArray Cumulative Operations API Reference
DESCRIPTION: This section provides the API signatures for various cumulative operations available as methods on `MLXArray` and as free functions in MLX Swift. These operations include `cummax`, `cummin`, `cumprod`, and `cumsum`, each offering overloaded versions to specify an axis, reverse computation, inclusivity, and a stream.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/Organization/cumulative.md#_snippet_1

LANGUAGE: APIDOC
CODE:
```
MLXArray Methods:
  cummax(axis: MLXArray.Axis?, reverse: Bool, inclusive: Bool, stream: MLXStream?)
  cummax(reverse: Bool, inclusive: Bool, stream: MLXStream?)
  cummin(axis: MLXArray.Axis?, reverse: Bool, inclusive: Bool, stream: MLXStream?)
  cummin(reverse: Bool, inclusive: Bool, stream: MLXStream?)
  cumprod(axis: MLXArray.Axis?, reverse: Bool, inclusive: Bool, stream: MLXStream?)
  cumprod(reverse: Bool, inclusive: Bool, stream: MLXStream?)
  cumsum(axis: MLXArray.Axis?, reverse: Bool, inclusive: Bool, stream: MLXStream?)
  cumsum(reverse: Bool, inclusive: Bool, stream: MLXStream?)

Free Functions:
  cummax(_ array: MLXArray, axis: MLXArray.Axis?, reverse: Bool, inclusive: Bool, stream: MLXStream?)
  cummax(_ array: MLXArray, reverse: Bool, inclusive: Bool, stream: MLXStream?)
  cummin(_ array: MLXArray, axis: MLXArray.Axis?, reverse: Bool, inclusive: Bool, stream: MLXStream?)
  cummin(_ array: MLXArray, reverse: Bool, inclusive: Bool, stream: MLXStream?)
  cumprod(_ array: MLXArray, axis: MLXArray.Axis?, reverse: Bool, inclusive: Bool, stream: MLXStream?)
  cumprod(_ array: MLXArray, reverse: Bool, inclusive: Bool, stream: MLXStream?)
  cumsum(_ array: MLXArray, axis: MLXArray.Axis?, reverse: Bool, inclusive: Bool, stream: MLXStream?)
  cumsum(_ array: MLXArray, reverse: Bool, inclusive: Bool, stream: MLXStream?)
```

----------------------------------------

TITLE: Core API Formatting Functions in fmt/core.h
DESCRIPTION: This section details the core formatting functions available in fmt/core.h. These functions use a format string syntax similar to Python's str.format and support compile-time checks in C++20. They take a format string (fmt::format_string or fmt::runtime for runtime strings) and an argument list (args). I/O errors are reported as std::system_error exceptions.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/doc/api.rst#_snippet_1

LANGUAGE: APIDOC
CODE:
```
Function: format
  Signature: format_string<T...> fmt, T&&... args
  Returns: std::string

Function: vformat
  Signature: string_view fmt, format_args args
  Returns: std::string

Function: format_to
  Signature: OutputIt out, format_string<T...> fmt, T&&... args
  Returns: OutputIt

Function: format_to_n
  Signature: OutputIt out, size_t n, format_string<T...> fmt, T&&... args
  Returns: format_to_n_result<OutputIt>

Function: formatted_size
  Signature: format_string<T...> fmt, T&&... args
  Returns: size_t
```

----------------------------------------

TITLE: MLXArray Aggregating Reduction Functions API Reference
DESCRIPTION: API documentation for aggregating reduction methods available on `MLXArray`, such as `logSumExp`, `product`, `max`, `mean`, `min`, `sum`, and `variance`, supporting different axis configurations.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/Organization/reduction.md#_snippet_2

LANGUAGE: APIDOC
CODE:
```
MLXArray methods:
- logSumExp(keepDims:stream:)
- logSumExp(axis:keepDims:stream:)
- logSumExp(axes:keepDims:stream:)
- product(keepDims:stream:)
- product(axis:keepDims:stream:)
- product(axes:keepDims:stream:)
- max(keepDims:stream:)
- max(axis:keepDims:stream:)
- max(axes:keepDims:stream:)
- mean(keepDims:stream:)
- mean(axis:keepDims:stream:)
- mean(axes:keepDims:stream:)
- min(keepDims:stream:)
- min(axis:keepDims:stream:)
- min(axes:keepDims:stream:)
- sum(keepDims:stream:)
- sum(axis:keepDims:stream:)
- sum(axes:keepDims:stream:)
- variance(keepDims:ddof:stream:)
- variance(axis:keepDims:ddof:stream:)
- variance(axes:keepDims:ddof:stream:)
```

----------------------------------------

TITLE: MLX Swift Aggregating Reduction Free Functions
DESCRIPTION: Details free functions in MLX Swift for aggregating reduction operations, including sum, product, mean, max, min, log sum exp, and variance across specified axes.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/free-functions.md#_snippet_8

LANGUAGE: APIDOC
CODE:
```
logSumExp(_:axes:keepDims:stream:)
product(_:axis:keepDims:stream:)
max(_:axes:keepDims:stream:)
mean(_:axes:keepDims:stream:)
min(_:axes:keepDims:stream:)
sum(_:axes:keepDims:stream:)
variance(_:axes:keepDims:ddof:stream:)
```

----------------------------------------

TITLE: Basic Format String Examples
DESCRIPTION: Illustrates simple format string usage, including explicit and implicit argument referencing.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/doc/syntax.rst#_snippet_0

LANGUAGE: Generic
CODE:
```
"First, thou shalt count to {0}" // References the first argument
"Bring me a {}"                  // Implicitly references the first argument
"From {} to {}"                  // Same as "From {0} to {1}"
```

----------------------------------------

TITLE: Debugging AutoreleasePool Leaks and Usage
DESCRIPTION: Provides methods to prevent and debug memory leaks related to autoreleased objects. It details the use of the `OBJC_DEBUG_MISSING_POOLS` environment variable for runtime warnings and the `leaks` command-line tool for inspecting AutoreleasePool contents.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/metal-cpp/README.md#_snippet_1

LANGUAGE: shell
CODE:
```
OBJC_DEBUG_MISSING_POOLS=YES
```

LANGUAGE: shell
CODE:
```
leaks --autoreleasePools <process_id_or_memgraph_file>
```

----------------------------------------

TITLE: Create Common MLXArray Patterns with Factory Methods in Swift
DESCRIPTION: Shows examples of using MLXArray's factory methods to quickly create arrays filled with zeros or identity matrices.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/Organization/initialization.md#_snippet_5

LANGUAGE: Swift
CODE:
```
// an array full of zeros
let zeros = MLXArray.zeros([5, 5])

// 2-d identity array
let identity = MLXArray.identity(5)
```

----------------------------------------

TITLE: MLXArray Subscript and Related Functions API
DESCRIPTION: API documentation for MLXArray's subscript functions and related array manipulation functions, including `take` and `takeAlong`.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/Organization/indexing.md#_snippet_9

LANGUAGE: APIDOC
CODE:
```
MLXArray Subscript Functions:
- MLXArray/subscript(_:stream:)-375a0
- MLXArray/subscript(_:stream:)-7crp3
- MLXArray/subscript(_:axis:stream:)-1jy5n
- MLXArray/subscript(_:axis:stream:)-79psf
- MLXArray/subscript(from:to:stride:axis:stream:)

Related Functions:
- MLXArray/take(_:axis:stream:)
- takeAlong(_:_:axis:stream:)
- <doc:converting-python>
```

----------------------------------------

TITLE: Apply Filter and Update Parameters (Swift)
DESCRIPTION: The `apply()` method combines filtering and updating parameters. This example demonstrates how to use `apply()` to iterate through parameters and convert all floating-point parameters to `.float16` data type.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLXNN/Documentation.docc/module-filters.md#_snippet_2

LANGUAGE: swift
CODE:
```
layer.apply { array in
    array.dtype.isFloatingPoint ? array.asType(.float16) : array
}
```

----------------------------------------

TITLE: Perform Binary Arithmetic Operations with MLXArray in Swift
DESCRIPTION: Demonstrates how to use binary arithmetic operators and equivalent free functions with MLXArray instances in Swift. It shows that both infix operators like '+' and functions like 'add' can achieve the same results for array arithmetic.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/Organization/arithmetic.md#_snippet_0

LANGUAGE: Swift
CODE:
```
let a = MLXArray(0 ..< 12, [4, 3])
let b = MLXArray([4, 5, 6])

// these are equivalent
let r1 = a + b + 7
let r2 = add(add(a, b), 7)
```

----------------------------------------

TITLE: Module Parameter Management API
DESCRIPTION: API documentation for methods related to managing and manipulating parameters within a Module instance, including applying filters, mapping, and updating parameters.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLXNN/Documentation.docc/Module.md#_snippet_0

LANGUAGE: APIDOC
CODE:
```
Module Parameters API:
- apply(filter:map:)
- filterMap(filter:map:isLeaf:)
- mapParameters(map:isLeaf:)
- parameters()
- trainableParameters()
- update(parameters:)
- update(parameters:verify:)
```

----------------------------------------

TITLE: Update Existing Git Submodules for MLX Swift
DESCRIPTION: If the `mlx-swift` repository was cloned without submodules, or if submodules need to be updated, this command forces them to initialize and update recursively. This ensures all necessary project dependencies are correctly present.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/troubleshooting.md#_snippet_1

LANGUAGE: Shell
CODE:
```
git submodule update --init --recursive
```

----------------------------------------

TITLE: Example Output of Mapping MLXNN Module Parameters
DESCRIPTION: This snippet illustrates the structured output generated when `mapParameters` is used to inspect the shapes of an `MLXNN` module's parameters. It shows a nested dictionary-like structure, detailing the `weight` parameter and its shape for each sub-module (`w1`, `w2`, `w3`).
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLXNN/Documentation.docc/custom-layers.md#_snippet_5

LANGUAGE: TEXT
CODE:
```
[
  w1: [
    weight: [64, 20]
  ],
  w2: [
    weight: [20, 64]
  ],
  w3: [
    weight: [20, 20]
  ]
]
```

----------------------------------------

TITLE: Install fmt Library using Homebrew
DESCRIPTION: Provides the command to install the fmt library on OS X using the Homebrew package manager. This is the standard and simplest way to install fmt for macOS users.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/doc/usage.rst#_snippet_19

LANGUAGE: Homebrew
CODE:
```
brew install fmt
```

----------------------------------------

TITLE: Specify Stream for MLXRandom Operations
DESCRIPTION: Demonstrates how to explicitly specify the computation stream (e.g., CPU or GPU) for MLX operations like random number generation using the `stream` argument. Operations without a specified stream run on the default stream of the default device.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/Articles/using-streams.md#_snippet_0

LANGUAGE: swift
CODE:
```
// produced on cpu
let a = MLXRandom.uniform([100, 100], stream: .cpu)

// produced on gpu
let b = MLXRandom.uniform([100, 100], stream: .gpu)
```

----------------------------------------

TITLE: Aggregating Reduction Free Functions API Reference
DESCRIPTION: API documentation for global aggregating reduction free functions, including `logSumExp`, `product`, `max`, `mean`, `min`, `std`, `sum`, and `variance` overloads for MLXArray instances.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/Organization/reduction.md#_snippet_4

LANGUAGE: APIDOC
CODE:
```
Global functions:
- logSumExp(_:keepDims:stream:)
- logSumExp(_:axis:keepDims:stream:)
- logSumExp(_:axes:keepDims:stream:)
- product(_:keepDims:stream:)
- product(_:axis:keepDims:stream:)
- product(_:axes:keepDims:stream:)
- max(_:keepDims:stream:)
- max(_:axis:keepDims:stream:)
- max(_:axes:keepDims:stream:)
- mean(_:keepDims:stream:)
- mean(_:axis:keepDims:stream:)
- mean(_:axes:keepDims:stream:)
- min(_:keepDims:stream:)
- min(_:axis:keepDims:stream:)
- min(_:axes:keepDims:stream:)
- std(_:axes:keepDims:ddof:stream:)
- std(_:axis:keepDims:ddof:stream:)
- std(_:keepDims:ddof:stream:)
- sum(_:keepDims:stream:)
- sum(_:axis:keepDims:stream:)
- sum(_:axes:keepDims:stream:)
- variance(_:keepDims:ddof:stream:)
- variance(_:axis:keepDims:ddof:stream:)
- variance(_:axes:keepDims:ddof:stream:)
```

----------------------------------------

TITLE: General Structure of fmt::formatter Specialization in C++
DESCRIPTION: This snippet outlines the general template structure for specializing `fmt::formatter<T>`. It details the `parse` method for processing format specifiers and the `format` method for writing the formatted value to the output context, emphasizing the importance of supporting standard specifiers like fill, align, and width.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/doc/api.rst#_snippet_10

LANGUAGE: C++
CODE:
```
template <> struct fmt::formatter<T> {
  // Parses format specifiers and stores them in the formatter.
  //
  // [ctx.begin(), ctx.end()) is a, possibly empty, character range that
  // contains a part of the format string starting from the format
  // specifications to be parsed, e.g. in
  //
  //   fmt::format("{:f} continued", ...);
  //
  // the range will contain "f} continued". The formatter should parse
  // specifiers until '}' or the end of the range. In this example the
  // formatter should parse the 'f' specifier and return an iterator
  // pointing to '}'.
  constexpr auto parse(format_parse_context& ctx)
    -> format_parse_context::iterator;

  // Formats value using the parsed format specification stored in this
  // formatter and writes the output to ctx.out().
  auto format(const T& value, format_context& ctx) const
    -> format_context::iterator;
};
```

----------------------------------------

TITLE: MLX Swift Quantization Functions
DESCRIPTION: This section details functions related to array quantization in MLX Swift. It includes methods for quantizing arrays, performing quantized matrix multiplication, and dequantizing arrays back to their original precision.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/free-functions.md#_snippet_11

LANGUAGE: APIDOC
CODE:
```
- ``quantized(_:groupSize:bits:stream:)``
- ``quantizedMatmul(_:_:scales:biases:transpose:groupSize:bits:stream:)``
- ``dequantized(_:scales:biases:groupSize:bits:stream:)``
```

----------------------------------------

TITLE: Get Sorted Indices of MLXArray (Swift)
DESCRIPTION: Demonstrates how to use `argSort` to obtain the indices that would sort an MLX array. These indices can then be used to reorder the original array into sorted order.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/Organization/sorting.md#_snippet_0

LANGUAGE: swift
CODE:
```
// array with values in random order
let array = MLXRandom.randInt(0 ..< 100, [10])

let sortIndexes = argSort(array, axis: -1)

// the array in sorted order
let sorted = array[sortIndexes]
```

----------------------------------------

TITLE: Perform Array Reduction Operations in Swift with MLXArray
DESCRIPTION: Demonstrates how to initialize an MLXArray and apply `sum()` for both total array sum and axis-specific sum, illustrating basic reduction functionality.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/Organization/reduction.md#_snippet_0

LANGUAGE: swift
CODE:
```
let array = MLXArray(0 ..< 12, [4, 3])

// scalar array with the sum of all the values
let totalSum = array.sum()

// array with the sum of the colums
let columnSum = array.sum(axis: 0)
```

----------------------------------------

TITLE: MLXArray Index Producing Functions API Reference
DESCRIPTION: Detailed API reference for MLX functions designed to produce array indices. These include `argMax`, `argMin`, `argPartition`, and `argSort`, which return indices based on specific criteria (e.g., maximum value, sorted order) along specified axes.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/Organization/indexes.md#_snippet_1

LANGUAGE: APIDOC
CODE:
```
MLXArray/argMax(keepDims:stream:)
MLXArray/argMax(axis:keepDims:stream:)
MLXArray/argMin(keepDims:stream:)
MLXArray/argMin(axis:keepDims:stream:)
argMax(_:keepDims:stream:)
argMax(_:axis:keepDims:stream:)
argMin(_:keepDims:stream:)
argMin(_:axis:keepDims:stream:)
argPartition(_:kth:stream:)
argPartition(_:kth:axis:stream:)
argSort(_:stream:)
argSort(_:axis:stream:)
```

----------------------------------------

TITLE: Perform Cumulative Sum on MLXArray in Swift
DESCRIPTION: This Swift code snippet demonstrates how to use the `cumsum()` method on an `MLXArray` to compute the cumulative sum of its elements. It initializes an array with values from 0 to 4 and then applies `cumsum()` to produce a new array where each element is the sum of all preceding elements plus itself.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/Organization/cumulative.md#_snippet_0

LANGUAGE: Swift
CODE:
```
// [0, 1, 2, 3, 4]
let array = MLXArray(0 ..< 5)

// [0, 1, 3, 6, 10]
let result = array.cumsum()
```

----------------------------------------

TITLE: MLX Swift Miscellaneous Array Operations
DESCRIPTION: This section provides documentation for various utility functions in MLX Swift that don't fit into other categories. It includes operations like extracting diagonals, Einstein summation, Hadamard transforms, view casting, and error handling mechanisms.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/free-functions.md#_snippet_14

LANGUAGE: APIDOC
CODE:
```
- ``diag(_:k:stream:)``
- ``diagonal(_:offset:axis1:axis2:stream:)``
- ``einsum(_:operands:stream:)``
- ``einsum(_:_:stream:)``
- ``hadamardTransform(_:scale:stream:)``
- ``view(_:dtype:stream:)``
- ``setErrorHandler(_:data:dtor:)``
- ``fatalErrorHandler``
```

----------------------------------------

TITLE: Comparing C++ Formatted Output: iostreams vs. printf
DESCRIPTION: This snippet compares the verbosity and conciseness of `iostreams` and `printf` for achieving formatted output in C++, highlighting the 'chevron hell' issue with `iostreams` compared to the more compact `printf` syntax.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/README.md#_snippet_11

LANGUAGE: c++
CODE:
```
std::cout << std::setprecision(2) << std::fixed << 1.23456 << "\n";
```

LANGUAGE: c++
CODE:
```
printf("%.2f\n", 1.23456);
```

----------------------------------------

TITLE: Install Project Headers and CMake Package Configuration
DESCRIPTION: This comprehensive CMake section manages the installation of project header files and generates/installs CMake configuration files (`Config.cmake`, `ConfigVersion.cmake`) for `find_package()` support. It also handles the export of targets and installation of the pkg-config file, ensuring the project can be easily consumed by other CMake-based projects.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/json/CMakeLists.txt#_snippet_8

LANGUAGE: CMake
CODE:
```
#
# INSTALL install header files, generate and install cmake config files for
# find_package()
#
include(CMakePackageConfigHelpers)
# use a custom package version config file instead of
# write_basic_package_version_file to ensure that it's architecture-independent
# https://github.com/nlohmann/json/issues/1697
configure_file("cmake/nlohmann_jsonConfigVersion.cmake.in"
               ${NLOHMANN_JSON_CMAKE_VERSION_CONFIG_FILE} @ONLY)
configure_file(${NLOHMANN_JSON_CMAKE_CONFIG_TEMPLATE}
               ${NLOHMANN_JSON_CMAKE_PROJECT_CONFIG_FILE} @ONLY)

if(JSON_Install)
  install(DIRECTORY ${NLOHMANN_JSON_INCLUDE_BUILD_DIR}
          DESTINATION ${NLOHMANN_JSON_INCLUDE_INSTALL_DIR})
  install(FILES ${NLOHMANN_JSON_CMAKE_PROJECT_CONFIG_FILE}
                ${NLOHMANN_JSON_CMAKE_VERSION_CONFIG_FILE}
          DESTINATION ${NLOHMANN_JSON_CONFIG_INSTALL_DIR})
  if(NLOHMANN_ADD_NATVIS)
    install(FILES ${NLOHMANN_NATVIS_FILE} DESTINATION .)
  endif()
  export(
    TARGETS ${NLOHMANN_JSON_TARGET_NAME}
    NAMESPACE ${PROJECT_NAME}::
    FILE ${NLOHMANN_JSON_CMAKE_PROJECT_TARGETS_FILE})
  install(
    TARGETS ${NLOHMANN_JSON_TARGET_NAME}
    EXPORT ${NLOHMANN_JSON_TARGETS_EXPORT_NAME}
    INCLUDES
    DESTINATION ${NLOHMANN_JSON_INCLUDE_INSTALL_DIR})
  install(
    EXPORT ${NLOHMANN_JSON_TARGETS_EXPORT_NAME}
    NAMESPACE ${PROJECT_NAME}::
    DESTINATION ${NLOHMANN_JSON_CONFIG_INSTALL_DIR})
  install(FILES "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.pc"
          DESTINATION ${NLOHMANN_JSON_PKGCONFIG_INSTALL_DIR})
endif()
```

----------------------------------------

TITLE: MLX Swift Element-wise Arithmetic Free Functions
DESCRIPTION: Lists free functions in MLX Swift for performing element-wise arithmetic operations on MLXArray instances, including basic mathematical, trigonometric, exponential, and comparison functions.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/free-functions.md#_snippet_0

LANGUAGE: APIDOC
CODE:
```
abs(_:stream:)
acos(_:stream:)
acosh(_:stream:)
add(_:_:stream:)
asin(_:stream:)
asinh(_:stream:)
atan(_:stream:)
atanh(_:stream:)
ceil(_:stream:)
clip(_:min:max:stream:)
clip(_:max:stream:)
cos(_:stream:)
cosh(_:stream:)
divide(_:_:stream:)
erf(_:stream:)
erfInverse(_:stream:)
exp(_:stream:)
expm1(_:stream:)
floor(_:stream:)
floorDivide(_:_:stream:)
log(_:stream:)
log10(_:stream:)
log1p(_:stream:)
log2(_:stream:)
logAddExp(_:_:stream:)
logicalNot(_:stream:)
matmul(_:_:stream:)
maximum(_:_:stream:)
minimum(_:_:stream:)
multiply(_:_:stream:)
negative(_:stream:)
notEqual(_:_:stream:)
pow(_:_:stream:)-7pe7j
pow(_:_:stream:)-49xi0
pow(_:_:stream:)-8ie9c
reciprocal(_:stream:)
remainder(_:_:stream:)
round(_:decimals:stream:)
rsqrt(_:stream:)
sigmoid(_:stream:)
sign(_:stream:)
sin(_:stream:)
sinh(_:stream:)
softmax(_:precise:stream:)
softmax(_:axis:precise:stream:)
softmax(_:axes:precise:stream:)
sqrt(_:stream:)
square(_:stream:)
subtract(_:_:stream:)
tan(_:stream:)
tanh(_:stream:)
which(_:_:_:stream:)
```

----------------------------------------

TITLE: MLXNN Activation Free Functions
DESCRIPTION: Lists the built-in free functions provided by MLXNN for various activation operations, including their parameters. These functions can be used directly.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLXNN/Documentation.docc/activations.md#_snippet_0

LANGUAGE: APIDOC
CODE:
```
celu(_:alpha:)
elu(_:alpha:)
gelu(_:)
geluApproximate(_:)
geluFastApproximate(_:)
glu(_:axis:)
hardSwish(_:)
leakyRelu(_:negativeSlope:)
logSigmoid(_:)
logSoftmax(_:axis:)
mish(_:)
prelu(_:alpha:)
relu(_:)
relu6(_:)
selu(_:)
silu(_:)
sigmoid(_:)
softplus(_:)
softsign(_:)
step(_:threshold:)
```

----------------------------------------

TITLE: MLXNN Activation Modules
DESCRIPTION: Lists the built-in modules provided by MLXNN that encapsulate activation functions. Some modules, like GELU, offer settings to select between different functions, while others, like CELU, encapsulate parameters such as 'alpha'.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLXNN/Documentation.docc/activations.md#_snippet_1

LANGUAGE: APIDOC
CODE:
```
CELU
GELU
GLU
HardSwish
LeakyReLU
LogSigmoid
LogSoftmax
Mish
PReLU
ReLU
ReLU6
SELU
SiLU
Sigmoid
Softmax-63x8p
Softplus
Softsign
Step
Tanh
```

----------------------------------------

TITLE: Create MLXArray from Scalar Values in Swift
DESCRIPTION: Demonstrates initializing zero-dimensional MLXArray instances from various scalar types (Boolean, Int, Double) and explicitly setting the DType for floating-point scalars.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/Organization/initialization.md#_snippet_0

LANGUAGE: Swift
CODE:
```
let v1 = MLXArray(true)
let v2 = MLXArray(7)
let v3 = MLXArray(8.5)
```

LANGUAGE: Swift
CODE:
```
// dtype is .float32
let v4 = MLXArray(8.5)

// dtype is .float16
let v5 = MLXArray(Float16(8.5))

// dtype is .float16
let v6 = MLXArray(8.5, dtype: .float16)
```

----------------------------------------

TITLE: Debugging MLX Compiled Functions: Crash on Array Evaluation
DESCRIPTION: This snippet illustrates a common debugging pitfall when working with MLX compiled functions: attempting to evaluate or print MLXArrays inside a compiled function will cause a crash. This happens because compiled functions are traced with placeholder inputs, preventing direct array inspection during execution.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/Articles/compilation.md#_snippet_4

LANGUAGE: Swift
CODE:
```
func f(_ x: MLXArray) -> MLXArray {
    let z = -x

    // this will crash
    print(z)

    return exp(z)
}

let compiled = compile(f)
_ = compiled(...)
```

----------------------------------------

TITLE: Implement TransformerBlock in Swift using ModuleInfo
DESCRIPTION: This Swift code implements the `TransformerBlock` module, showcasing the use of the `@ModuleInfo` property wrapper. It allows specifying replacement keys (e.g., `key: "feed_forward"`) to align Swift variable names with their original Python definitions, facilitating compatibility and module updates. The `wrappedValue` is used for initialization.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLXNN/Documentation.docc/custom-layers.md#_snippet_8

LANGUAGE: Swift
CODE:
```
public class TransformerBlock : Module {

    let attention: Attention

    @ModuleInfo(key: "feed_forward") var feedForward: FeedForward
    @ModuleInfo(key: "attention_norm") var attentionNorm: RMSNorm
    @ModuleInfo(key: "ffn_norm") var ffnNorm: RMSNorm

    public init(_ args: Configuration) {
        self.attention = Attention(args)
        self._feedForward.wrappedValue = FeedForward(args)
        self._attentionNorm.wrappedValue = RMSNorm(args.dimensions, eps: args.normEps)
        self._ffnNorm.wrappedValue = RMSNorm(args.dimensions, eps: args.normEps)
    }
```

----------------------------------------

TITLE: MLX Swift: Capturing Global Random State for Compiled Functions
DESCRIPTION: To ensure that random number generation works as expected within compiled functions, the global random state (`MLXRandom.globalState`) must be explicitly captured. By including it in both `inputs` and `outputs` parameters of `compile`, random numbers will change with each function call.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/Articles/compilation.md#_snippet_9

LANGUAGE: swift
CODE:
```
// now cature the random state and the random numbers should change per call
let c2 = compile(inputs: [MLXRandom.globalState], outputs: [MLXRandom.globalState], f)

let c2a = c2(bias)
let c2b = c2(bias)
XCTAssertFalse(allClose(c2a, c2b).item())
```

----------------------------------------

TITLE: Add CMake Test for Find Package Functionality
DESCRIPTION: This CMake snippet defines a CTest entry named `find-package-test`. Its purpose is to verify that project targets can be correctly found from the build directory. It uses `ctest` to build and test a specific project, passing essential CMake variables like compiler, flags, and build type as options. This test is disabled on Windows and GCC versions older than 4.9.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/test/CMakeLists.txt#_snippet_11

LANGUAGE: CMake
CODE:
```
add_test(
    find-package-test
    ${CMAKE_CTEST_COMMAND}
    -C
    ${CMAKE_BUILD_TYPE}
    --build-and-test
    "${CMAKE_CURRENT_SOURCE_DIR}/find-package-test"
    "${CMAKE_CURRENT_BINARY_DIR}/find-package-test"
    --build-generator
    ${CMAKE_GENERATOR}
    --build-makeprogram
    ${CMAKE_MAKE_PROGRAM}
    --build-options
    "-DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}"
    "-DCMAKE_CXX_FLAGS=${CMAKE_CXX_FLAGS}"
    "-DCMAKE_CXX_STANDARD=${CMAKE_CXX_STANDARD}"
    "-DFMT_DIR=${PROJECT_BINARY_DIR}"
    "-DPEDANTIC_COMPILE_FLAGS=${PEDANTIC_COMPILE_FLAGS}"
    "-DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}")
```

----------------------------------------

TITLE: MLXNN Built-in Layers Overview
DESCRIPTION: A comprehensive list of built-in neural network layers provided by MLXNN, categorized into Unary, Sampling, Recurrent, and Other Layers. These layers can be used to construct models, often with `Sequential`.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLXNN/Documentation.docc/layers.md#_snippet_0

LANGUAGE: APIDOC
CODE:
```
Unary Layers:
  Description: Layers that provide an interface that takes a single MLXArray and produces a single MLXArray. These can be used with Sequential.
  Layers:
    - AvgPool1d
    - AvgPool2d
    - Conv1d
    - Conv2d
    - Conv3d
    - ConvTransposed1d
    - ConvTransposed2d
    - ConvTransposed3d
    - Dropout
    - Dropout2d
    - Dropout3d
    - Embedding
    - Identity
    - Linear
    - MaxPool1d
    - MaxPool2d
    - QuantizedLinear
    - RMSNorm
    - Sequential

Sampling Layers:
  Layers:
    - Upsample

Recurrent Layers:
  Layers:
    - RNN
    - GRU
    - LSTM

Other Layers:
  Layers:
    - Bilinear
    - MultiHeadAttention
```

----------------------------------------

TITLE: Efficient Formatting with fmt::memory_buffer
DESCRIPTION: Shows how to use `fmt::memory_buffer` and `fmt::format_to` to format data directly into a buffer, avoiding `std::string` construction for performance-critical scenarios. It provides access to the raw data pointer and size.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/doc/index.rst#_snippet_1

LANGUAGE: C++
CODE:
```
auto out = fmt::memory_buffer();
fmt::format_to(std::back_inserter(out),
            "For a moment, {} happened.", "nothing");
auto data = out.data(); // pointer to the formatted data
auto size = out.size(); // size of the formatted data
```

----------------------------------------

TITLE: Integrate Custom Types with std::ostream and fmt::formatter
DESCRIPTION: Demonstrates how to enable formatting of user-defined types via std::ostream by specializing fmt::formatter and inheriting from ostream_formatter. This allows fmt::format to use the type's operator<<.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/doc/api.rst#_snippet_34

LANGUAGE: C++
CODE:
```
#include <fmt/ostream.h>

struct date {
  int year, month, day;

  friend std::ostream& operator<<(std::ostream& os, const date& d) {
    return os << d.year << '-' << d.month << '-' << d.day;
  }
};

template <> struct fmt::formatter<date> : ostream_formatter {};

std::string s = fmt::format("The date is {}", date{2012, 12, 9});
// s == "The date is 2012-12-9"
```

----------------------------------------

TITLE: NS::SharedPtr for Manual Memory Management
DESCRIPTION: Introduces `NS::SharedPtr<>`, a metal-cpp specific shared pointer template optimized for its memory model. It outlines its factory functions, `NS::TransferPtr()` for ownership transfer and `NS::RetainPtr()` for shared ownership and lifecycle extension.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/metal-cpp/README.md#_snippet_2

LANGUAGE: APIDOC
CODE:
```
NS::SharedPtr<T>:
  Description: Optional shared pointer template in metal-cpp, optimized for its memory model by leveraging NS::Object reference counting.
  Destructor: Always calls `release()` on the wrapped pointer.

Factory Functions:
  NS::TransferPtr(pointer: T*):
    Purpose: Transfers ownership of `pointer` to a new `NS::SharedPtr` instance.
    Behavior: Does not increase the pointee's retain count. Suitable for RAII.

  NS::RetainPtr(pointer: T*):
    Purpose: Shares ownership of `pointer` with another entity.
    Behavior: Creates a strong reference and increases the pointee's retain count. Can extend an object's lifecycle beyond an AutoreleasePool instance's scope.
```

----------------------------------------

TITLE: MLX Swift Array Factory Free Functions
DESCRIPTION: Describes free functions in MLX Swift for creating and initializing MLXArray instances with specific values or patterns, such as zeros, ones, identity, and linspace.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/free-functions.md#_snippet_4

LANGUAGE: APIDOC
CODE:
```
MLX/zeros(_:type:stream:)
MLX/zeros(like:stream:)
MLX/ones(_:type:stream:)
MLX/ones(like:stream:)
MLX/eye(_:m:k:type:stream:)
MLX/full(_:values:type:stream:)
MLX/full(_:values:stream:)
MLX/identity(_:type:stream:)
MLX/linspace(_:_:count:stream:)-7vj0o
MLX/linspace(_:_:count:stream:)-6w959
MLX/repeated(_:count:axis:stream:)
MLX/repeated(_:count:stream:)
MLX/repeat(_:count:axis:stream:)
MLX/repeat(_:count:stream:)
MLX/tri(_:m:k:type:stream:)
tril(_:k:stream:)
triu(_:k:stream:)
```

----------------------------------------

TITLE: MLXNN Module Class API Reference
DESCRIPTION: Details the core Module class in MLXNN, its role as a container for parameters and submodules, and methods for parameter management like parameters() and freeze().
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLXNN/Documentation.docc/MLXNN.md#_snippet_0

LANGUAGE: APIDOC
CODE:
```
Module Class:
  Description: A container of MLXArray or Module instances. Its main function is to provide a way to recursively access and update its parameters and those of its submodules.
  Parameters:
    - Any member of type MLXArray (its name should not start with '_'). Can be nested in other Module instances or Array and Dictionary.
  Methods:
    - parameters(): Extracts a NestedDictionary (ModuleParameters) with all the parameters of a module and its submodules.
    - freeze(recursive:keys:strict:): Manages "frozen" parameters. Gradients returned by valueAndGrad will be with respect to these trainable parameters.
```

----------------------------------------

TITLE: MLX Swift Logical Free Functions
DESCRIPTION: Outlines free functions in MLX Swift for performing logical operations on arrays, including comparisons, equality checks, and boolean operations.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/free-functions.md#_snippet_6

LANGUAGE: APIDOC
CODE:
```
all(_:axes:keepDims:stream:)
all(_:keepDims:stream:)
all(_:axis:keepDims:stream:)
allClose(_:_:rtol:atol:equalNaN:stream:)
any(_:axes:keepDims:stream:)
any(_:keepDims:stream:)
any(_:axis:keepDims:stream:)
arrayEqual(_:_:equalNAN:stream:)
equal(_:_:stream:)
greater(_:_:stream:)
greaterEqual(_:_:stream:)
less(_:_:stream:)
lessEqual(_:_:stream:)
logicalNot(_:stream:)
notEqual(_:_:stream:)
where(_:_:_:stream:)
```

----------------------------------------

TITLE: MLXArray Instance Factory Methods in Swift
DESCRIPTION: Details static factory methods available on the MLXArray class for creating new arrays with specific properties, such as arrays of zeros, ones, identity matrices, or repeated values.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/Organization/initialization.md#_snippet_11

LANGUAGE: APIDOC
CODE:
```
MLXArray Factory Methods:
  - MLXArray/zeros(_:type:stream:)
  - MLXArray/zeros(like:stream:)
  - MLXArray/zeros(_:dtype:stream:)
  - MLXArray/ones(_:type:stream:)
  - MLXArray/ones(like:stream:)
  - MLXArray/ones(_:dtype:stream:)
  - MLXArray/eye(_:m:k:type:stream:)
  - MLXArray/full(_:values:type:stream:)
  - MLXArray/full(_:values:stream:)
  - MLXArray/identity(_:type:stream:)
  - MLXArray/linspace(_:_:count:stream:)-92x6l
  - MLXArray/linspace(_:_:count:stream:)-7m7eg
  - MLXArray/repeated(_:count:axis:stream:)
  - MLXArray/repeated(_:count:stream:)
  - MLXArray/repeat(_:count:axis:stream:)
  - MLXArray/repeat(_:count:stream:)
  - MLXArray/tri(_:m:k:type:stream:)
```

----------------------------------------

TITLE: MLXArray Array Initializers in Swift
DESCRIPTION: Lists various initializers for creating MLXArray instances from existing arrays or sequences, including conversion options.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/Organization/initialization.md#_snippet_9

LANGUAGE: APIDOC
CODE:
```
MLXArray Array Initializers:
  - MLXArray/init(_:_:)-4n0or
  - MLXArray/init(_:_:)-dq8h
  - MLXArray/init(_:_:)-89jw1
  - MLXArray/init(converting:_:)
  - MLXArray/init(_:_:type:)-5esf9
  - MLXArray/init(_:_:type:)-f9u5
```

----------------------------------------

TITLE: Module Filter and Map Functions API Reference
DESCRIPTION: Reference for key/value filter functions, `isLeaf` functions, and map functions available in the `Module` class, usable with methods like `Module/filterMap(filter:map:isLeaf:)`, `Module/apply(filter:map:)`, and `Module/mapParameters(map:isLeaf:)`.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLXNN/Documentation.docc/module-filters.md#_snippet_3

LANGUAGE: APIDOC
CODE:
```
Key/Value Filter Functions:
  - Module/filterAll
  - Module/filterLocalParameters
  - Module/filterOther
  - Module/filterTrainableParameters
  - Module/filterValidChild
  - Module/filterValidParameters

isLeaf Functions:
  - Module/isLeafDefault
  - Module/isLeafModule
  - Module/isLeafModuleNoChildren

Map Functions:
  - Module/mapModule(map:)
  - Module/mapOther(map:)
  - Module/mapParameters(map:)
```

----------------------------------------

TITLE: Compile-time format string validation with fmt (C++)
DESCRIPTION: Illustrates how the `fmt` library provides compile-time checking for format strings in C++20, catching errors like using an invalid format specifier (`d`) for a string type. This snippet demonstrates an intentional error for validation.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/README.md#_snippet_5

LANGUAGE: C++
CODE:
```
std::string s = fmt::format("{:d}", "I am not a number");
```

----------------------------------------

TITLE: Compile-Time Type Safety Error Example with FMT_STRING
DESCRIPTION: Illustrates how `FMT_STRING` can enable compile-time error reporting for format string mismatches on compilers supporting relaxed `constexpr`, preventing runtime issues.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/doc/index.rst#_snippet_8

LANGUAGE: C++
CODE:
```
format(FMT_STRING("The answer is {:d}"), "forty-two");
```

----------------------------------------

TITLE: MLX Swift Convolution Free Functions
DESCRIPTION: Documents free functions in MLX Swift for performing various convolution operations, including 1D, 2D, and general convolution.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/free-functions.md#_snippet_1

LANGUAGE: APIDOC
CODE:
```
conv1d(_:_:stride:padding:dilation:groups:stream:)
conv2d(_:_:stride:padding:dilation:groups:stream:)
convolve(_:_:mode:stream:)
```

----------------------------------------

TITLE: Convert Double Arrays for MLXArray Initialization in Swift
DESCRIPTION: Provides an example of converting a Swift Double array to an MLXArray, as MLXArray does not directly support Double types and performs an implicit conversion to Float.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/Organization/initialization.md#_snippet_3

LANGUAGE: Swift
CODE:
```
// this converts to a Float array behind the scenes
let v1 = MLXArray(converting: [0.1, 0.5])
```

----------------------------------------

TITLE: MLX Swift I/O Free Functions
DESCRIPTION: Covers free functions in MLX Swift for loading and saving MLXArray data from and to URLs.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/free-functions.md#_snippet_5

LANGUAGE: APIDOC
CODE:
```
loadArray(url:stream:)
loadArrays(url:stream:)
loadArraysAndMetadata(url:stream:)
save(array:url:stream:)
save(arrays:metadata:url:stream:)
```

----------------------------------------

TITLE: Printing to Standard Output with fmt::print
DESCRIPTION: Demonstrates the default behavior of `fmt::print` when no stream argument is provided, which is to print the formatted output to `stdout`.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/doc/index.rst#_snippet_3

LANGUAGE: C++
CODE:
```
fmt::print("Don't {}\n", "panic");
```

----------------------------------------

TITLE: Printing to Standard Error with fmt::print
DESCRIPTION: Illustrates how to use `fmt::print` to output formatted text to a specified stream, such as `stderr`, useful for logging error messages.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/doc/index.rst#_snippet_2

LANGUAGE: C++
CODE:
```
fmt::print(stderr, "System error code = {}\n", errno);
```

----------------------------------------

TITLE: Configure CMake Project with FMT Library
DESCRIPTION: This CMake snippet demonstrates how to configure a project, find the `fmt` library, add an executable, link against `fmt` (both shared and header-only versions), set compiler options, and include necessary directories. It ensures `fmt` is properly integrated for compilation and linking within a C++ project.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/test/find-package-test/CMakeLists.txt#_snippet_0

LANGUAGE: CMake
CODE:
```
cmake_minimum_required(VERSION 3.8...3.25)

project(fmt-test)

find_package(FMT REQUIRED)

add_executable(library-test main.cc)
target_link_libraries(library-test fmt::fmt)
target_compile_options(library-test PRIVATE ${PEDANTIC_COMPILE_FLAGS})
target_include_directories(library-test PUBLIC SYSTEM .)

if(TARGET fmt::fmt-header-only)
  add_executable(header-only-test main.cc)
  target_link_libraries(header-only-test fmt::fmt-header-only)
  target_compile_options(header-only-test PRIVATE ${PEDANTIC_COMPILE_FLAGS})
  target_include_directories(header-only-test PUBLIC SYSTEM .)
endif()
```

----------------------------------------

TITLE: Module Layer and Sub-module Management API
DESCRIPTION: API documentation for methods related to managing and interacting with sub-modules (layers) within a Module, including retrieving children, filtering, and updating modules.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLXNN/Documentation.docc/Module.md#_snippet_1

LANGUAGE: APIDOC
CODE:
```
Module Layers API:
- children()
- filterMap(filter:map:isLeaf:)
- leafModules()
- modules()
- namedModules()
- update(modules:)
- update(modules:verify:)
- visit(modules:)
```

----------------------------------------

TITLE: Define fmt::formatter for C++ Class Hierarchies
DESCRIPTION: This snippet demonstrates how to create a `fmt::formatter` specialization that works with a hierarchy of classes (`A` and `B`). It uses `std::enable_if_t` and `std::is_base_of` to conditionally apply the formatter, allowing polymorphic formatting based on the base class.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/doc/api.rst#_snippet_11

LANGUAGE: C++
CODE:
```
// demo.h:
#include <type_traits>
#include <fmt/core.h>

struct A {
  virtual ~A() {}
  virtual std::string name() const { return "A"; }
};

struct B : A {
  virtual std::string name() const { return "B"; }
};

template <typename T>
struct fmt::formatter<T, std::enable_if_t<std::is_base_of<A, T>::value, char>> :
    fmt::formatter<std::string> {
  auto format(const A& a, format_context& ctx) const {
    return fmt::formatter<std::string>::format(a.name(), ctx);
  }
};

// demo.cc:
#include "demo.h"
#include <fmt/format.h>

int main() {
  B b;
  A& a = b;
  fmt::print("{}", a); // prints "B"
}
```

----------------------------------------

TITLE: Dynamic Format Argument Store API
DESCRIPTION: The `fmt/args.h` header provides `dynamic_format_arg_store`, a builder-like API that allows for constructing format argument lists at runtime, offering flexibility for dynamic formatting scenarios.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/doc/api.rst#_snippet_15

LANGUAGE: APIDOC
CODE:
```
fmt::dynamic_format_arg_store
```

----------------------------------------

TITLE: Locale-Aware Formatting Example
DESCRIPTION: This C++ code demonstrates how to use the 'L' format specifier with `fmt::format` to insert appropriate number separator characters based on the currently set global locale, such as displaying '1,000,000' for one million in an 'en_US.UTF-8' locale.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/doc/api.rst#_snippet_23

LANGUAGE: C++
CODE:
```
#include <fmt/core.h>
#include <locale>

std::locale::global(std::locale("en_US.UTF-8"));
auto s = fmt::format("{:L}", 1000000);  // s == "1,000,000"
```

----------------------------------------

TITLE: Map and Inspect MLXNN Module Parameters Shapes in Swift
DESCRIPTION: This Swift code demonstrates using the `mapParameters` method on an `MLXNN` module to get detailed information about its internal `MLXArray` parameters. The example specifically maps each parameter to its `shape` property, providing a structured view of the parameter dimensions.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLXNN/Documentation.docc/custom-layers.md#_snippet_4

LANGUAGE: Swift
CODE:
```
print(layer.mapParameters { $0.shape })
```

----------------------------------------

TITLE: Map All Parameters to Get Shapes (Swift)
DESCRIPTION: This snippet shows a simple way to apply a map function to the entire set of parameters using `mapParameters()`. Optional `isLeaf` control is available for more granular traversal.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLXNN/Documentation.docc/module-filters.md#_snippet_1

LANGUAGE: swift
CODE:
```
let parameterShapes = module.mapParameters { $0.shape }
```

----------------------------------------

TITLE: MLX Swift Array Sorting and Partitioning Functions
DESCRIPTION: This section provides documentation for functions that sort and partition MLX arrays. It covers operations like `argSort` to get sorted indices, `argPartition` for partial sorting, and `sorted` and `partitioned` for direct array manipulation.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/free-functions.md#_snippet_10

LANGUAGE: APIDOC
CODE:
```
- ``argSort(_:axis:stream:)``
- ``argPartition(_:kth:axis:stream:)``
- ``sorted(_:stream:)``
- ``sorted(_:axis:stream:)``
- ``partitioned(_:kth:stream:)``
- ``partitioned(_:kth:axis:stream:)``
```

----------------------------------------

TITLE: MLXArray Integer Initialization Overrides in Swift
DESCRIPTION: Explains how MLXArray handles integer initializers, defaulting to DType/int32 for Swift's Int type, and provides specific initializers for explicitly requesting DType/int64.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/Organization/initialization.md#_snippet_8

LANGUAGE: APIDOC
CODE:
```
MLXArray Int Overrides:
  - MLXArray/init(_:)-6nnka
  - MLXArray/init(_:_:)-93flk
  - MLXArray/init(int64:)
  - MLXArray/init(int64:_:)-7bgj2
  - MLXArray/init(int64:_:)-74tu0
```

----------------------------------------

TITLE: MLXArray Index Consuming Functions API Reference
DESCRIPTION: Detailed API reference for MLX functions that consume array indices. This includes `MLXArray`'s subscripting capabilities and functions like `take` and `takeAlong`, which use provided indices to extract or reorder elements within an `MLXArray`.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/Organization/indexes.md#_snippet_2

LANGUAGE: APIDOC
CODE:
```
MLXArray/subscript(_:stream:)-375a0
MLXArray/take(_:axis:stream:)
takeAlong(_:_:axis:stream:)
```

----------------------------------------

TITLE: Create Custom Logging Function with fmt::vprint in C++
DESCRIPTION: This snippet presents an example of building a custom logging function (`log`) and a macro (`MY_LOG`) using `fmt::vprint` and `fmt::make_format_args`. It highlights how to create a `vlog` function that is not parameterized on argument types, which helps improve compile times.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/doc/api.rst#_snippet_13

LANGUAGE: C++
CODE:
```
#include <fmt/core.h>

void vlog(const char* file, int line, fmt::string_view format,
          fmt::format_args args) {
  fmt::print("{}: {}: ", file, line);
  fmt::vprint(format, args);
}

template <typename... T>
void log(const char* file, int line, fmt::format_string<T...> format, T&&... args) {
  vlog(file, line, format, fmt::make_format_args(args...));
}

#define MY_LOG(format, ...) log(__FILE__, __LINE__, format, __VA_ARGS__)

MY_LOG("invalid squishiness: {}", 42);
```

----------------------------------------

TITLE: Mapping of mx Free Functions to MLX Swift Equivalents
DESCRIPTION: This section details the direct correspondence between common `mx` free functions and their equivalent free functions available in the MLX Swift library. It serves as a reference for understanding parallel functionalities and migrating code.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/Articles/converting-python.md#_snippet_3

LANGUAGE: APIDOC
CODE:
```
mx.abs -> MLX/abs(_:stream:)
mx.add -> MLX/add(_:_:stream:)
mx.all -> MLX/all(_:axes:keepDims:stream:)
mx.allclose -> MLX/allClose(_:_:rtol:atol:equalNaN:stream:)
mx.any -> MLX/any(_:axes:keepDims:stream:)
mx.arange -> MLXArray/init(_:_:)-4n0or
mx.arccos -> MLX/acos(_:stream:)
mx.arccosh -> MLX/acosh(_:stream:)
mx.arcsin -> MLX/asin(_:stream:)
mx.arcsinh -> MLX/asinh(_:stream:)
mx.arctan -> MLX/atan(_:stream:)
mx.arctanh -> MLX/atanh(_:stream:)
mx.argmax -> MLX/argMax(_:axis:keepDims:stream:)
mx.argmin -> MLX/argMin(_:axis:keepDims:stream:)
mx.argpartition -> MLX/argPartition(_:kth:axis:stream:)
mx.argsort -> MLX/argSort(_:axis:stream:)
mx.array_equal -> MLX/arrayEqual(_:_:equalNAN:stream:)
mx.as_strided -> MLX/asStrided(_:_:strides:offset:stream:)
mx.broadcast_to -> MLX/broadcast(_:to:stream:)
mx.ceil -> MLX/ceil(_:stream:)
mx.clip -> MLX/clip(_:min:max:stream:)
mx.concatenate -> MLX/concatenated(_:axis:stream:)
mx.conv1d -> MLX/conv1d(_:_:stride:padding:dilation:groups:stream:)
mx.conv2d -> MLX/conv2d(_:_:stride:padding:dilation:groups:stream:)
mx.convolve -> MLX/convolve(_:_:mode:stream:)
mx.cos -> MLX/cos(_:stream:)
mx.cosh -> MLX/cosh(_:stream:)
mx.cummax -> MLX/cummax(_:axis:reverse:inclusive:stream:)
mx.cummin -> MLX/cummin(_:axis:reverse:inclusive:stream:)
mx.cumprod -> MLX/cumprod(_:axis:reverse:inclusive:stream:)
mx.cumsum -> MLX/cumsum(_:axis:reverse:inclusive:stream:)
mx.dequantize -> MLX/dequantized(_:scales:biases:groupSize:bits:stream:)
mx.divide -> MLX/divide(_:_:stream:)
mx.equal -> MLX/equal(_:_:stream:)
mx.erf -> MLX/erf(_:stream:)
mx.erfinv -> MLX/erfInverse(_:stream:)
mx.exp -> MLX/exp(_:stream:)
mx.expand_dims -> MLX/expandedDimensions(_:axes:stream:)
mx.eye -> MLXArray/eye(_:m:k:type:stream:)
mx.flatten -> MLX/flattened(_:start:end:stream:)
mx.floor -> MLX/floor(_:stream:)
mx.floor_divide -> MLX/floorDivide(_:_:stream:)
mx.full -> MLXArray/full(_:values:type:stream:)
mx.greater -> MLX/greater(_:_:stream:)
mx.greater_equal -> MLX/greaterEqual(_:_:stream:)
mx.identity -> MLXArray/identity(_:type:stream:)
mx.less -> MLX/less(_:_:stream:)
mx.less_equal -> MLX/lessEqual(_:_:stream:)
mx.linspace -> MLXArray/linspace(_:_:count:stream:)-92x6l
mx.load -> MLX/loadArray(url:stream:) and MLX/loadArrays(url:stream:)
mx.log -> MLX/log(_:stream:)
mx.log10 -> MLX/log10(_:stream:)
mx.log1p -> MLX/log1p(_:stream:)
mx.log2 -> MLX/log2(_:stream:)
mx.logaddexp -> MLX/logAddExp(_:_:stream:)
mx.logical_not -> MLX/logicalNot(_:stream:)
mx.logsumexp -> MLX/logSumExp(_:axes:keepDims:stream:)
mx.matmul -> MLX/matmul(_:_:stream:)
mx.max -> MLX/max(_:axes:keepDims:stream:)
mx.maximum -> MLX/maximum(_:_:stream:)
mx.mean -> MLX/mean(_:axes:keepDims:stream:)
mx.min -> MLX/min(_:axes:keepDims:stream:)
mx.minimum -> MLX/minimum(_:_:stream:)
mx.moveaxis -> MLX/movedAxis(_:source:destination:stream:)
mx.multiply -> MLX/multiply(_:_:stream:)
mx.negative -> MLX/negative(_:stream:)
mx.not_equal -> MLX/notEqual(_:_:stream:)
mx.ones -> MLXArray/ones(_:type:stream:)
mx.ones_like -> MLXArray/ones(like:stream:)
mx.pad -> MLX/padded(_:width:mode:value:stream:)
mx.partition -> MLX/partitioned(_:kth:axis:stream:)
mx.power -> MLX/pow(_:_:stream:)-8ie9c
mx.prod -> MLX/product(_:axes:keepDims:stream:)
mx.quantize -> MLX/quantized(_:groupSize:bits:stream:)
mx.quantized_matmul -> MLX/quantizedMatmul(_:_:scales:biases:transpose:groupSize:bits:stream:)
mx.reciprocal -> MLX/reciprocal(_:stream:)
mx.remainder -> MLX/remainder(_:_:stream:)
mx.repeat -> MLX/repeated(_:count:axis:stream:)
mx.reshape -> MLX/reshaped(_:_:stream:)-5x3y0
mx.round -> MLX/round(_:decimals:stream:)
mx.rsqrt -> MLX/rsqrt(_:stream:)
mx.save -> MLX/save(array:url:stream:) and MLX/save(arrays:metadata:url:stream:)
mx.save_safetensors -> MLX/save(arrays:metadata:url:stream:)
mx.savez -> not supported
mx.savez_compressed -> not supported
mx.sigmoid -> MLX/sigmoid(_:stream:)
mx.sign -> MLX/sign(_:stream:)
mx.sin -> MLX/sin(_:stream:)
mx.sinh -> MLX/sinh(_:stream:)
mx.softmax -> MLX/softmax(_:axes:precise:stream:)
mx.sort -> MLX/sorted(_:axis:stream:)
mx.split -> MLX/split(_:parts:axis:stream:)
mx.sqrt -> MLX/sqrt(_:stream:)
mx.square -> MLX/square(_:stream:)
mx.squeeze -> MLX/squeezed(_:axes:stream:)
mx.stack -> MLX/stacked(_:axis:stream:)
mx.stop_gradient -> MLX/stopGradient(_:stream:)
mx.subtract -> MLX/subtract(_:_:stream:)
mx.sum -> MLX/sum(_:axes:keepDims:stream:)
mx.swapaxes -> MLX/swappedAxes(_:_:_:stream:)
mx.take -> MLX/take(_:_:axis:stream:)
mx.take_along_axis -> MLX/takeAlong(_:_:axis:stream:)
mx.tan -> MLX/tan(_:stream:)
mx.tanh -> MLX/tanh(_:stream:)
mx.topk -> MLX/top(_:k:axis:stream:)
```

----------------------------------------

TITLE: Define Target Linear Function for Training in MLX Swift
DESCRIPTION: This Swift function 'f' defines the ground truth linear relationship (y = 0.25x + 7) that the 'LinearFunctionModel' aims to learn. It serves as the source for generating 'y' values during training.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLXNN/Documentation.docc/training.md#_snippet_3

LANGUAGE: swift
CODE:
```
func f(_ x: MLXArray) -> MLXArray {
    // these are the target parameters
    let m = 0.25
    let b = 7

    // our actual function
    return m * x + b
}
```

----------------------------------------

TITLE: fmt/color.h API Reference for Terminal Styling
DESCRIPTION: API documentation for functions supporting terminal color and text style output using fmt/color.h.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/doc/api.rst#_snippet_32

LANGUAGE: APIDOC
CODE:
```
Functions:
  print(const text_style &ts, const S &format_str, const Args&... args): Prints formatted text with specified style.
  fg(detail::color_type): Sets foreground color.
  bg(detail::color_type): Sets background color.
  styled(const T& value, text_style ts): Applies a text style to a value.
```

----------------------------------------

TITLE: Build and Test MLX Swift Projects with Xcodebuild
DESCRIPTION: These shell commands illustrate how to use `xcodebuild` for command-line operations on MLX Swift projects. Examples include running tests for the `mlx-swift-Package` scheme and building the `Tutorial` scheme, both targeting the OS X platform.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/README.md#_snippet_1

LANGUAGE: Shell
CODE:
```
# build and run tests
xcodebuild test -scheme mlx-swift-Package -destination 'platform=OS X'
```

LANGUAGE: Shell
CODE:
```
# build Tutorial
xcodebuild build -scheme Tutorial -destination 'platform=OS X'
```

----------------------------------------

TITLE: Use ScalarOrArray Protocol with MLXArray in Swift
DESCRIPTION: Illustrates how the ScalarOrArray protocol allows numeric scalars to be used implicitly with MLXArray operations, converting them to MLXArray instances with a suggested DType.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/Organization/initialization.md#_snippet_1

LANGUAGE: Swift
CODE:
```
let values: [Float16] = [ 0.5, 1.0, 2.5 ]

// a has dtype .float16
let a = MLXArray(values)

// b also has dtype .float16 because this translates (roughly) to:
// t = Int(3).asMLXArray(dtype: .float16)
// let b = a + t
let b = a + 3
```

----------------------------------------

TITLE: MLX Swift Ellipsis with New Axis Appending
DESCRIPTION: Shows how to append a new axis to an MLXArray using the `ellipsis` operator in conjunction with `.newAxis`, similar to `array[..., None]` in Python.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/Organization/indexing.md#_snippet_8

LANGUAGE: swift
CODE:
```
// python array[..., None]
array[.ellipsis, .newAxis]
```

----------------------------------------

TITLE: Built-in Positional Encoding Layers in MLX Swift
DESCRIPTION: This section lists the available positional encoding layers provided by MLX Swift. These layers are designed to be integrated into neural network models to incorporate positional information.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLXNN/Documentation.docc/positional-encoding.md#_snippet_0

LANGUAGE: APIDOC
CODE:
```
Positional Encoding Layers:
- RoPE
- SinusoidalPositionalEncoding
- ALiBi
```

----------------------------------------

TITLE: Print with colors and text styles using fmt::color (C++)
DESCRIPTION: Shows how to apply colors and text styles (bold, underline, italic) to printed output using `fmt::print` and `<fmt/color.h>`. It demonstrates combining foreground color, background color, and emphasis.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/README.md#_snippet_7

LANGUAGE: C++
CODE:
```
#include <fmt/color.h>

int main() {
  fmt::print(fg(fmt::color::crimson) | fmt::emphasis::bold,
             "Hello, {}!\n", "world");
  fmt::print(fg(fmt::color::floral_white) | bg(fmt::color::slate_gray) |
             fmt::emphasis::underline, "Olá, {}!\n", "Mundo");
  fmt::print(fg(fmt::color::steel_blue) | fmt::emphasis::italic,
             "你好{}！\n", "世界");
}
```

----------------------------------------

TITLE: MLXArray Indexing Mapping from Python to Swift
DESCRIPTION: This section provides a mapping of common `numpy`-style indexing operations from Python's `mx.array` to Swift's `MLXArray`, highlighting syntax differences and similarities.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/Articles/converting-python.md#_snippet_0

LANGUAGE: Python
CODE:
```
array[10]
array[-1]
array.shape[0]
array.shape[-1]
array[1, 2, 3]
array[2:8]
array[:, :8, 8:]
array[array2]
array[array2, array3]
array[None]
array[:, None]
array[..., None]
array[:, -1, :]
array[..., ::2]
array[::-1]
array[..., ::-1]
array.shape[:-1]
```

LANGUAGE: Swift
CODE:
```
array[10]
array[-1]
array.dim(0) // or array.shape[0]
array.dim(-1)
array[1, 2, 3]
array[2 ..< 8]
array[0..., ..<8, 8...]
array[array2]
array[array2, array3]
array[.newAxis]
array[0..., .newAxis]
array[.ellipsis, .newAxis]
array[0..., -1, 0...]
array[.ellipsis, .stride(by: 2)]
array[.stride(by: -1)] // reverse first dimension
array[.ellipsis, stride(by: -1)] // reverse last dimension
array.shape.dropLast()
```

----------------------------------------

TITLE: Print a container with fmt::ranges (C++)
DESCRIPTION: Shows how to print the contents of a standard container like `std::vector` using `fmt::print` and including `<fmt/ranges.h>`. The output automatically formats the container elements.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/README.md#_snippet_4

LANGUAGE: C++
CODE:
```
#include <vector>
#include <fmt/ranges.h>

int main() {
  std::vector<int> v = {1, 2, 3};
  fmt::print("{}\n", v);
}
```

----------------------------------------

TITLE: C++ fmt Library Text Alignment and Width
DESCRIPTION: Shows how to align text within a specified width using `fmt::format`. It covers left (`<`), right (`>`), and center (`^`) alignment, and demonstrates how to use a custom fill character (e.g., `*`) instead of the default space.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/doc/syntax.rst#_snippet_26

LANGUAGE: C++
CODE:
```
fmt::format("{:<30}", "left aligned");
// Result: "left aligned                  "
```

LANGUAGE: C++
CODE:
```
fmt::format("{:>30}", "right aligned");
// Result: "                 right aligned"
```

LANGUAGE: C++
CODE:
```
fmt::format("{:^30}", "centered");
// Result: "           centered           "
```

LANGUAGE: C++
CODE:
```
fmt::format("{:*^30}", "centered");  // use '*' as a fill char
// Result: "***********centered***********"
```

----------------------------------------

TITLE: Swift Function to Measure MLXArray Operation Performance
DESCRIPTION: This helper function, `measure`, is designed to benchmark the execution time of MLXArray operations in Swift. It includes a warm-up phase and calculates the average time per iteration over multiple runs, providing a reliable performance measurement.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/Articles/compilation.md#_snippet_2

LANGUAGE: Swift
CODE:
```
func measure(_ f: (MLXArray) -> MLXArray, _ x: MLXArray) {
    // warm up
    for _ in 0 ..< 10 {
        eval(f(x))
    }

    let start = Date.timeIntervalSinceReferenceDate
    let iterations = 100
    for _ in 0 ..< iterations {
        eval(f(x))
    }
    let end = Date.timeIntervalSinceReferenceDate

    let timePerIteration = 1000.0 * (end - start) / Double(iterations)

    print("Time per iteration \(timePerIteration.formatted()) ms")
}
```

----------------------------------------

TITLE: MLX Swift Array Conversion Functions API
DESCRIPTION: Documents various conversion functions available for `MLXArray` in MLX Swift, enabling transformations between data types, array representations, and extraction of real/imaginary components.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/Organization/conversion.md#_snippet_0

LANGUAGE: APIDOC
CODE:
```
MLXArray:
  - asType(_:stream:)-4eqoc: Converts the array to a specified DType.
  - asType(_:stream:)-6d44y: Converts the array to a specified DType. (Overloaded)
  - asArray(_:): Converts the MLXArray to a standard Swift Array.
  - asData(noCopy:): Converts the MLXArray to Data.
  - asMTLBuffer(device:noCopy:): Converts the MLXArray to an MTLBuffer for Metal operations.
  - asImaginary(stream:): Converts the array to its imaginary part.
  - imaginaryPart(stream:): Extracts the imaginary part of the array.
  - realPart(stream:): Extracts the real part of the array.
```

----------------------------------------

TITLE: MLX Index Producing Functions API Reference
DESCRIPTION: API documentation for MLX functions that generate indices for sorting and partitioning. These indices typically need to be applied to an `MLXArray` using subscripting or `take`.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/Organization/sorting.md#_snippet_2

LANGUAGE: APIDOC
CODE:
```
MLX Index Producing Functions:
- argSort(_:axis:stream:)
- argPartition(_:kth:axis:stream:)
```

----------------------------------------

TITLE: Using Scalar Arrays for Control Flow in MLX Swift
DESCRIPTION: This Swift function shows how scalar MLXArrays can be used for control flow, which implicitly triggers an evaluation. While functional and compatible with gradient transformations, this pattern can be inefficient if evaluations occur too frequently.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/Articles/lazy-evaluation.md#_snippet_3

LANGUAGE: swift
CODE:
```
func f(_ x: MLXArray) -> MLXArray {
    let (h, y) = firstLayer(x)

    // note: in python this is just "if y > 0:" which
    // has an implicit item() call in the boolean context
    let z: MLXArray
    if (y > 0).item() {
        z = secondLayerA(h)
    } else {
        z = secondLayerB(h)
    }
    return z
}
```

----------------------------------------

TITLE: MLX Global Factory Methods for MLXArray in Swift
DESCRIPTION: Describes global factory methods provided by the MLX module for creating MLXArray instances, similar to the MLXArray class methods but accessible directly from the MLX namespace.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/Organization/initialization.md#_snippet_12

LANGUAGE: APIDOC
CODE:
```
MLXArray Factory Free Methods:
  - MLX/zeros(_:type:stream:)
  - MLX/zeros(like:stream:)
  - MLX/ones(_:type:stream:)
  - MLX/ones(like:stream:)
  - MLX/eye(_:m:k:type:stream:)
  - MLX/full(_:values:type:stream:)
  - MLX/full(_:values:stream:)
  - MLX/identity(_:type:stream:)
  - MLX/linspace(_:_:count:stream:)-7vj0o
  - MLX/linspace(_:_:count:stream:)-6w959
  - MLXArray/repeated(_:count:axis:stream:)
  - MLXArray/repeated(_:count:stream:)
  - MLX/repeat(_:count:axis:stream:)
  - MLX/repeat(_:count:stream:)
  - MLX/tri(_:m:k:type:stream:)
```

----------------------------------------

TITLE: fmt/chrono.h API Reference
DESCRIPTION: API documentation for date and time related formatting functions provided by fmt/chrono.h.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/doc/api.rst#_snippet_28

LANGUAGE: APIDOC
CODE:
```
Functions:
  localtime(std::time_t time): Converts a std::time_t value to a local time structure.
  gmtime(std::time_t time): Converts a std::time_t value to a UTC time structure.
```

----------------------------------------

TITLE: Chrono Format Conversion Specifier Meanings
DESCRIPTION: Provides a comprehensive list of available `chrono_type` conversion specifiers for chrono formatting, detailing their meaning and examples. It also notes potential exceptions like `format_error` for invalid values.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/doc/syntax.rst#_snippet_16

LANGUAGE: APIDOC
CODE:
```
Type: 'a'
Meaning: The abbreviated weekday name, e.g. "Sat". If the value does not contain a valid weekday, an exception of type `format_error` is thrown.

Type: 'A'
Meaning: The full weekday name, e.g. "Saturday". If the value does not contain a valid weekday, an exception of type `format_error` is thrown.

Type: 'b'
Meaning: The abbreviated month name, e.g. "Nov". If the value does not contain a valid month, an exception of type `format_error` is thrown.

Type: 'B'
Meaning: The full month name, e.g. "November". If the value does not contain a valid month, an exception of type `format_error` is thrown.

Type: 'c'
Meaning: The date and time representation, e.g. "Sat Nov 12 22:04:00 1955". The modified command `%Ec` produces the locale's alternate date and time representation.
```

----------------------------------------

TITLE: Free Functions for MLXArray Shape Manipulation
DESCRIPTION: Global functions that operate on MLXArray instances to manipulate their shapes, often involving broadcasting, concatenation, or padding.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/Organization/shapes.md#_snippet_3

LANGUAGE: APIDOC
CODE:
```
asStrided(_:_:strides:offset:stream:)
broadcast(_:to:stream:)
concatenated(_:axis:stream:)
expandedDimensions(_:axes:stream:)
movedAxis(_:source:destination:stream:)
padded(_:width:mode:value:stream:)
padded(_:widths:mode:value:stream:)
split(_:indices:axis:stream:)
split(_:parts:axis:stream:)
split(_:axis:stream:)
stacked(_:axis:stream:)
swappedAxes(_:_:_:stream:)
tiled(_:repetitions:stream:)-72ntc
tiled(_:repetitions:stream:)-eouf
transposed(_:axes:stream:)
```

----------------------------------------

TITLE: Understanding AutoreleasePool Memory Management in metal-cpp
DESCRIPTION: Explains the role of AutoreleasePools in metal-cpp for managing temporary object lifetimes, detailing how objects are added and released. It also covers scenarios for extending object ownership beyond a pool's scope.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/metal-cpp/README.md#_snippet_0

LANGUAGE: APIDOC
CODE:
```
AutoreleasePool:
  Purpose: Manages lifetimes of temporary objects created by metal-cpp methods that do not begin with `alloc`, `new`, `copy`, `mutableCopy`, or `Create`.
  Behavior:
    - Objects are added to the pool upon creation.
    - The pool releases its objects when it is released (drained).
    - Typical scope: one rendering frame for the main thread; drained when control returns to the RunLoop.
    - Custom pools: Can be created at smaller scopes to reduce working set, required for additional threads.
  Ownership Extension:
    - Call `retain()` on an object before the pool is drained to extend its lifecycle.
    - Responsibility for `release()` falls to the caller in such cases.
```

----------------------------------------

TITLE: Perform Arithmetic Operations with Scalars and MLXArray in Swift
DESCRIPTION: Explains how MLXArray handles arithmetic operations involving scalar values. It demonstrates the ScalarOrArray protocol, showing how a scalar Int is implicitly converted to an MLXArray with the correct DType for operations like addition, ensuring type consistency.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/Organization/arithmetic.md#_snippet_2

LANGUAGE: Swift
CODE:
```
let values: [Float16] = [ 0.5, 1.0, 2.5 ]

// a has dtype .float16
let a = MLXArray(values)

// b also has dtype .float16 because this translates (roughly) to:
// t = Int(3).asMLXArray(dtype: .float16)
// let b = a + t
let b = a + 3
```

----------------------------------------

TITLE: MLX Swift API: transpose Function
DESCRIPTION: Documents the API path and signature for the `transpose` function in MLX Swift, used for reordering array dimensions.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/Articles/converting-python.md#_snippet_4

LANGUAGE: APIDOC
CODE:
```
Function: transpose
Path: MLX/transposed(_:axes:stream:)
```

----------------------------------------

TITLE: MLXOptimizers Base Classes and Protocols Reference
DESCRIPTION: This section outlines the fundamental base classes and protocols within MLXOptimizers, such as `Optimizer` and `OptimizerBase`. These provide the foundational structure for implementing and extending custom optimizers.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLXOptimizers/Documentation.docc/MLXOptimizers.md#_snippet_2

LANGUAGE: APIDOC
CODE:
```
Base Classes and Protocols:
  - Optimizer
  - OptimizerBase
  - OptimizerBaseArrayState
```

----------------------------------------

TITLE: C++ fmt Library Dynamic Width and Precision
DESCRIPTION: Explains how to specify width and precision dynamically using arguments in `fmt::format`. This allows for flexible formatting where the width or precision is determined at runtime by another argument provided to the format function.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/doc/syntax.rst#_snippet_27

LANGUAGE: C++
CODE:
```
fmt::format("{:<{}}", "left aligned", 30);
// Result: "left aligned                  "
```

LANGUAGE: C++
CODE:
```
fmt::format("{:.{}f}", 3.14, 1);
// Result: "3.1"
```

----------------------------------------

TITLE: MLX Swift Array Shape Manipulation Functions
DESCRIPTION: This section documents functions designed for manipulating the shape and dimensions of MLX arrays. It includes operations such as striding, broadcasting, concatenation, expanding and moving dimensions, padding, reshaping, splitting, squeezing, stacking, and transposing arrays.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/free-functions.md#_snippet_9

LANGUAGE: APIDOC
CODE:
```
- ``asStrided(_:_:strides:offset:stream:)``
- ``broadcast(_:to:stream:)``
- ``concatenated(_:axis:stream:)``
- ``expandedDimensions(_:axes:stream:)``
- ``expandedDimensions(_:axis:stream:)``
- ``movedAxis(_:source:destination:stream:)``
- ``padded(_:width:mode:value:stream:)``
- ``padded(_:widths:mode:value:stream:)``
- ``reshaped(_:_:stream:)-5x3y0``
- ``reshaped(_:_:stream:)-96lgr``
- ``split(_:indices:axis:stream:)``
- ``split(_:parts:axis:stream:)``
- ``split(_:axis:stream:)``
- ``squeezed(_:stream:)``
- ``squeezed(_:axis:stream:)``
- ``squeezed(_:axes:stream:)``
- ``stacked(_:axis:stream:)``
- ``swappedAxes(_:_:_:stream:)``
- ``transposed(_:stream:)``
- ``transposed(_:axis:stream:)``
- ``transposed(_:axes:stream:)``
- ``transposed(_:_:stream:)``
- ``T(_:stream:)``
```

----------------------------------------

TITLE: MLXArray Shape Manipulation (Changing Contents)
DESCRIPTION: Methods that manipulate both the shape and the contents of an MLXArray, potentially changing the number of elements or their arrangement.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/Organization/shapes.md#_snippet_2

LANGUAGE: APIDOC
CODE:
```
MLXArray/movedAxis(source:destination:stream:)
MLXArray/split(parts:axis:stream:)
MLXArray/split(indices:axis:stream:)
MLXArray/split(axis:stream:)
MLXArray/swappedAxes(_:_:stream:)
MLXArray/transposed(stream:)
MLXArray/transposed(axis:stream:)
MLXArray/transposed(axes:stream:)
MLXArray/transposed(_:stream:)
MLXArray/T
```

----------------------------------------

TITLE: Core API Printing Functions in fmt
DESCRIPTION: This section describes the fmt::print and fmt::vprint functions, which provide direct printing capabilities to standard output or a specified std::FILE pointer. They utilize the same format string syntax as other core formatting functions for consistent usage.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/doc/api.rst#_snippet_3

LANGUAGE: APIDOC
CODE:
```
Function: fmt::print
  Signature: format_string<T...> fmt, T&&... args
  Returns: void

Function: fmt::vprint
  Signature: string_view fmt, format_args args
  Returns: void

Function: print
  Signature: std::FILE *f, format_string<T...> fmt, T&&... args
  Returns: void

Function: vprint
  Signature: std::FILE *f, string_view fmt, format_args args
  Returns: void
```

----------------------------------------

TITLE: Print MLXNN Module Architecture in Swift
DESCRIPTION: This Swift snippet shows the simplest way to inspect the architecture of an `MLXNN` module. Printing the `layer` object directly displays a human-readable representation of its sub-modules and their configurations.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLXNN/Documentation.docc/custom-layers.md#_snippet_2

LANGUAGE: Swift
CODE:
```
print(layer)
```

----------------------------------------

TITLE: C++ fmt Library Positional Argument Access
DESCRIPTION: Illustrates how to access arguments by their position using `fmt::format`. Arguments can be referenced explicitly by index (e.g., `{0}`) or implicitly in order (e.g., `{}`). This feature allows for reordering and repeating arguments within the format string.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/doc/syntax.rst#_snippet_25

LANGUAGE: C++
CODE:
```
fmt::format("{0}, {1}, {2}", 'a', 'b', 'c');
// Result: "a, b, c"
```

LANGUAGE: C++
CODE:
```
fmt::format("{}, {}, {}", 'a', 'b', 'c');
// Result: "a, b, c"
```

LANGUAGE: C++
CODE:
```
fmt::format("{2}, {1}, {0}", 'a', 'b', 'c');
// Result: "c, b, a"
```

LANGUAGE: C++
CODE:
```
fmt::format("{0}{1}{0}", "abra", "cad");  // arguments' indices can be repeated
// Result: "abracadabra"
```

----------------------------------------

TITLE: Logical Reduction Free Functions API Reference
DESCRIPTION: API documentation for global logical reduction free functions, including `all` and `any` overloads for MLXArray instances.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/Organization/reduction.md#_snippet_3

LANGUAGE: APIDOC
CODE:
```
Global functions:
- all(_:keepDims:stream:)
- all(_:axis:keepDims:stream:)
- all(_:axes:keepDims:stream:)
- any(_:keepDims:stream:)
- any(_:axis:keepDims:stream:)
- any(_:axes:keepDims:stream:)
```

----------------------------------------

TITLE: Sign Option for Numeric Formatting
DESCRIPTION: The 'sign' option is applicable to floating point and signed integer types, controlling the display of positive and negative signs.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/doc/syntax.rst#_snippet_4

LANGUAGE: APIDOC
CODE:
```
Option: '+'
  Meaning: Indicates that a sign should be used for both nonnegative as well as negative numbers.
Option: '-'
  Meaning: Indicates that a sign should be used only for negative numbers (this is the default behavior).
Option: 'space'
  Meaning: Indicates that a leading space should be used on nonnegative numbers, and a minus sign on negative numbers.
```

----------------------------------------

TITLE: Build MLXOptimizers Swift Library
DESCRIPTION: Compiles the MLXOptimizers Swift library from its source files and defines it as a static library. It links privately against the core MLX and MLXNN libraries, indicating its dependencies on these components.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/CMakeLists.txt#_snippet_7

LANGUAGE: CMake
CODE:
```
file(GLOB MLXOptimizers-src
     ${CMAKE_CURRENT_LIST_DIR}/Source/MLXOptimizers/*.swift)
add_library(MLXOptimizers STATIC ${MLXOptimizers-src})
target_link_libraries(MLXOptimizers PRIVATE MLX MLXNN)
```

----------------------------------------

TITLE: MLX Swift Ellipsis with Stride and Reverse
DESCRIPTION: Illustrates how the `ellipsis` operator can be combined with `stride` to apply operations like striding or reversing the last axis of an MLXArray, mirroring Python's slicing syntax.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/Organization/indexing.md#_snippet_7

LANGUAGE: swift
CODE:
```
// stride the last axis by 2
// python: array[..., ::2]
array[.ellipsis, .stride(by: 2)]

// reverse the last axis
// python: array[..., ::-1]
array[.ellipsis, .stride(by: -1)]
```

----------------------------------------

TITLE: iOS Simulator Metal GPU Assertion Error
DESCRIPTION: This code snippet shows a common error message encountered when attempting to run MLX applications on the iOS simulator. The error indicates that the simulator does not support certain Metal features required by MLX, specifically non-uniform threadgroup sizes, necessitating development on actual devices or specific Xcode targets.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/Articles/running-on-ios.md#_snippet_2

LANGUAGE: Plaintext
CODE:
```
failed assertion `Dispatch Threads with Non-Uniform Threadgroup Size is not supported on this device'
```

----------------------------------------

TITLE: MLXArray Swift Naming Conventions for Element-wise Operations and Transformations
DESCRIPTION: This section details the Swift naming conventions for `MLXArray` operations, including element-wise logical operations that follow SIMD conventions and function/method renamings from `snake_case` to `camelCase` for functions without side effects.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/Articles/converting-python.md#_snippet_1

LANGUAGE: APIDOC
CODE:
```
Swift Naming Conventions for MLXArray:

Element-wise Logical Operations:
  - MLXArray/.==(_:_:)-56m0a
  - MLXArray/.==(_:_:)-79hbc
  - Other SIMD operators (e.g., .<)
  Description: These operators produce a new MLXArray with true/false values for element-wise comparison, following Swift's SIMD conventions.

Function and Method Renaming (Python snake_case to Swift camelCase):
  - Python: flatten()
    Swift: flattened(_:start:end:stream:)
  - Python: reshape()
    Swift: reshaped(_:_:stream:)-5x3y0
  - Python: moveaxis()
    Swift: movedAxis(_:source:destination:stream:)
  Description: Functions that have no side effects are typically renamed from Python's snake_case to Swift's camelCase, often with a 'd' suffix for past participle forms.
```

----------------------------------------

TITLE: MLX Swift: Compiled Functions and Uncaptured Constants
DESCRIPTION: Compiled functions treat any inputs not included in their parameter list as constants. This means that implicit state, such as the global random seed, will not be updated or affect subsequent calls if it's not explicitly captured during compilation.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/Articles/compilation.md#_snippet_8

LANGUAGE: swift
CODE:
```
func f(_ bias: MLXArray) -> MLXArray {
    MLXRandom.uniform(0 ..< 1, [4]) + bias
}

let bias = MLXArray(0)

// without capturing state this won't mutate the random state
let c1 = compile(f)

let c1a = c1(bias)
let c1b = c1(bias)
XCTAssertTrue(allClose(c1a, c1b).item())
```

----------------------------------------

TITLE: Locate Python Interpreter in CMake (Version-Dependent)
DESCRIPTION: This CMake code block finds the Python interpreter, adapting its approach based on the CMake version. For CMake versions less than 3.12, it uses `find_package(PythonInterp)`. For 3.12 and newer, it uses `find_package(Python)` and explicitly sets `PYTHON_EXECUTABLE` to ensure compatibility.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/doc/CMakeLists.txt#_snippet_1

LANGUAGE: CMake
CODE:
```
if(CMAKE_VERSION VERSION_LESS 3.12)
  # This logic is deprecated in CMake after 3.12.
  find_package(PythonInterp QUIET REQUIRED)
else()
  find_package(Python QUIET REQUIRED)
  set(PYTHON_EXECUTABLE ${Python_EXECUTABLE})
endif()
```

----------------------------------------

TITLE: MLX Swift API: where Function
DESCRIPTION: Documents the API path and signature for the `where` (which) function in MLX Swift, used for conditional element selection.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/Articles/converting-python.md#_snippet_9

LANGUAGE: APIDOC
CODE:
```
Function: where
Path: MLX/which(_:_:_:stream:)
```

----------------------------------------

TITLE: 'e' Format Specifier
DESCRIPTION: The day of month as a decimal number. If the result is a single decimal digit, it is prefixed with a space. The modified command %Oe produces the locale's alternative representation.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/doc/syntax.rst#_snippet_20

LANGUAGE: APIDOC
CODE:
```
e: Day of month as decimal. Prefixed with space if single digit. Modified by %Oe.
```

----------------------------------------

TITLE: Format C++ Tuples and Ranges with fmt::print and fmt::join
DESCRIPTION: Demonstrates how to format std::tuple objects using fmt::print for default output and fmt::join for custom element separation. Requires including <fmt/ranges.h>.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/doc/api.rst#_snippet_26

LANGUAGE: C++
CODE:
```
#include <fmt/ranges.h>

std::tuple<char, int, float> t{'a', 1, 2.0f};
// Prints "('a', 1, 2.0)"
fmt::print("{}", t);
```

LANGUAGE: C++
CODE:
```
#include <fmt/ranges.h>

std::tuple<int, char> t = {1, 'a'};
// Prints "1, a"
fmt::print("{}", fmt::join(t, ", "));
```

----------------------------------------

TITLE: Numeric Formatting Precision Rules
DESCRIPTION: Explains the default precision behavior for general numeric formatting, including rules for handling exponents, trailing zeros, and special values like infinity and NaN. This applies when no specific precision is given.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/doc/syntax.rst#_snippet_13

LANGUAGE: APIDOC
CODE:
```
Type: none
Meaning: Similar to 'g', except that the default precision is as high as needed to represent the particular value.

Precise rules:
Suppose that the result formatted with presentation type 'e' and precision p-1 would have exponent exp. Then if -4 <= exp < p, the number is formatted with presentation type 'f' and precision p-1-exp. Otherwise, the number is formatted with presentation type 'e' and precision p-1. In both cases insignificant trailing zeros are removed from the significand, and the decimal point is also removed if there are no remaining digits following it.

Special values:
Positive and negative infinity: inf, -inf
Positive and negative zero: 0, -0
NaNs: nan
(Formatted regardless of precision)
```

----------------------------------------

TITLE: MLXArray Initializer and Operator API References
DESCRIPTION: References to various MLXArray initializers and operators, including those for array literals and scalar values, providing an overview of available constructors and common operations.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/Organization/initialization.md#_snippet_7

LANGUAGE: APIDOC
CODE:
```
MLXArray/init(arrayLiteral:)
MLXArray/init(_:)-9iiz7
MLXArray/init(_:)-6zp01
MLXArray/init(_:)-86r8u
MLXArray/init(_:)-10m
MLXArray/init(_:)-96nyv
MLXArray/init(_:dtype:)
MLXArray/init(bfloat16:)
MLXArray/+(_:_:)-2vili
MLXArray/+(_:_:)-1jn5i
MLX/minimum(_:_:stream:)
MLX/pow(_:_:stream:)-7pe7j
MLX/pow(_:_:stream:)-49xi0
```

----------------------------------------

TITLE: Format C++ Date and Time Types with fmt/chrono.h
DESCRIPTION: Illustrates formatting std::time_t, std::chrono::duration, and std::chrono::time_point using fmt/chrono.h. Examples include strftime-like formatting and default duration output.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/doc/api.rst#_snippet_27

LANGUAGE: C++
CODE:
```
#include <fmt/chrono.h>

int main() {
  std::time_t t = std::time(nullptr);

  // Prints "The date is 2020-11-07." (with the current date):
  fmt::print("The date is {:%Y-%m-%d}.", fmt::localtime(t));

  using namespace std::literals::chrono_literals;

  // Prints "Default format: 42s 100ms":
  fmt::print("Default format: {} {}\n", 42s, 100ms);

  // Prints "strftime-like format: 03:15:30":
  fmt::print("strftime-like format: {:%H:%M:%S}\n", 3h + 15min + 30s);
}
```

----------------------------------------

TITLE: Print dates and times with fmt::chrono (C++)
DESCRIPTION: Demonstrates how to format and print current dates and times using `fmt::print` in conjunction with `<fmt/chrono.h>`. It shows both full timestamp and custom time formatting.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/README.md#_snippet_3

LANGUAGE: C++
CODE:
```
#include <fmt/chrono.h>

int main() {
  auto now = std::chrono::system_clock::now();
  fmt::print("Date and time: {}\n", now);
  fmt::print("Time: {:%H:%M}\n", now);
}
```

----------------------------------------

TITLE: Example Output of Printing MLXNN Module
DESCRIPTION: This snippet provides an example of the console output when an `MLXNN` module, such as the `FeedForward` layer, is printed. It clearly lists the sub-modules (`w1`, `w2`, `w3`) and their respective `Linear` layer configurations, including input/output dimensions and bias settings.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLXNN/Documentation.docc/custom-layers.md#_snippet_3

LANGUAGE: TEXT
CODE:
```
FeedForward {
  w1: Linear(inputDimensions=20, outputDimensions=64, bias=false),
  w2: Linear(inputDimensions=64, outputDimensions=20, bias=false),
  w3: Linear(inputDimensions=20, outputDimensions=20, bias=false),
}
```

----------------------------------------

TITLE: fmt::arg Function Reference for Named Arguments
DESCRIPTION: This entry provides API documentation for the `fmt::arg` function, which is used to create named arguments for formatting. It notes that named arguments are not currently supported in compile-time checks.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/doc/api.rst#_snippet_12

LANGUAGE: APIDOC
CODE:
```
fmt::arg(const S&, const T&)
```

----------------------------------------

TITLE: Link to Header-Only fmt Library with CMake
DESCRIPTION: CMake command to link a target against the header-only version of the fmt library, suitable for projects that don't require the compiled library.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/doc/usage.rst#_snippet_7

LANGUAGE: CMake
CODE:
```
target_link_libraries(<your-target> PRIVATE fmt::fmt-header-only)
```

----------------------------------------

TITLE: Overview of Formatting User-Defined Types in fmt
DESCRIPTION: The {fmt} library provides mechanisms to make user-defined types formattable. This section introduces two primary methods: providing a format_as function or specializing the formatter struct template. The format_as function is simpler, allowing a type to be formatted like another existing formattable type.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/doc/api.rst#_snippet_5

LANGUAGE: APIDOC
CODE:
```
Two ways to make a user-defined type formattable:
1. Providing a format_as function:
   - Use if you want to make your type formattable as some other type with the same format specifiers.
   - Function should take an object of your type and return an object of a formattable type.
   - Should be defined in the same namespace as your type.
2. Specializing the formatter struct template:
   - More complex, but gives full control over parsing and formatting.
```

----------------------------------------

TITLE: Configure Package.swift for New MLX Swift Package
DESCRIPTION: Illustrates how to modify `Package.swift` to add a new library product and target, and update test dependencies for a new MLX Swift package like `MLXFFT`.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/MAINTENANCE.md#_snippet_1

LANGUAGE: Swift
CODE:
```
products: [
    ...
    .library(name: "MLXFFT", targets: ["MLXFFT"]),

```

LANGUAGE: Swift
CODE:
```
targets: [
    ...
    .target(
        name: "MLXFFT",
        dependencies: ["MLX"]
    ),

```

LANGUAGE: Swift
CODE:
```
        .testTarget(
            name: "MLXTests",
            dependencies: ["MLX", "MLXRandom", "MLXNN", "MLXOptimizers", "MLXFFT"]
        ),

```

----------------------------------------

TITLE: MLX Swift API: zeros Function
DESCRIPTION: Documents the API path and signature for the `zeros` function in MLX Swift, used for creating arrays filled with zeros.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/Articles/converting-python.md#_snippet_10

LANGUAGE: APIDOC
CODE:
```
Function: zeros
Path: MLXArray/zeros(_:type:stream:)
```

----------------------------------------

TITLE: Filter and Map Local Parameters to Get Shapes (Swift)
DESCRIPTION: This example demonstrates how to use the `filterMap()` method to limit traversal to only local parameters directly attached to a module. It then maps these parameters to their shapes, producing a `NestedDictionary<String, [Int]>`.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLXNN/Documentation.docc/module-filters.md#_snippet_0

LANGUAGE: swift
CODE:
```
// produces NestedDictionary<String, [Int]> for the parameters attached
// directly to this module
let localParameterShapes = module.filterMap(
    filter: Module.filterLocalParameters,
    map: Module.mapParameters { $0.shape })
```

----------------------------------------

TITLE: Locale 'L' Option for Number Separators
DESCRIPTION: The 'L' option enables the use of current locale settings to insert appropriate number separator characters, valid only for numeric types.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/doc/syntax.rst#_snippet_8

LANGUAGE: APIDOC
CODE:
```
Option: 'L'
  Description: Uses the current locale setting to insert appropriate number separator characters.
  Restrictions: Only valid for numeric types.
```

----------------------------------------

TITLE: MLX Direct Sorting and Partitioning Functions API Reference
DESCRIPTION: API documentation for MLX functions that directly sort or partition data, producing a new array. These functions return the processed array directly.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/Organization/sorting.md#_snippet_3

LANGUAGE: APIDOC
CODE:
```
MLX Direct Sorting and Partitioning Functions:
- sorted(_:axis:stream:)
- partitioned(_:kth:axis:stream:)
```

----------------------------------------

TITLE: Initializing Input Arrays for Mixed-Device Example (Swift)
DESCRIPTION: Initializes two MLX arrays, 'a' and 'b', with random uniform values. These arrays serve as inputs for the 'f' function, demonstrating the setup for a mixed-device computation where data is created once and accessed by different devices.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/Articles/unified-memory.md#_snippet_4

LANGUAGE: Swift
CODE:
```
let a = MLXRandom.uniform([4096, 512])
let b = MLXRandom.uniform([512, 4])
```

----------------------------------------

TITLE: Enable fmt Library Testing
DESCRIPTION: This CMake snippet conditionally enables testing for the `fmt` library. If the `FMT_TEST` option is set, it enables CTest and includes the `test` subdirectory, allowing the project's unit tests to be built and run.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/CMakeLists.txt#_snippet_25

LANGUAGE: CMake
CODE:
```
if(FMT_TEST)
  enable_testing()
  add_subdirectory(test)
endif()
```

----------------------------------------

TITLE: MLX Swift API: zeros_like Function
DESCRIPTION: Documents the API path and signature for the `zeros_like` function in MLX Swift, used for creating zero-filled arrays with the same shape and type as another array.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/Articles/converting-python.md#_snippet_11

LANGUAGE: APIDOC
CODE:
```
Function: zeros_like
Path: MLXArray/zeros(like:stream:)
```

----------------------------------------

TITLE: MLX Swift New Axis Operator
DESCRIPTION: Demonstrates the `newAxis` operator in MLX Swift, which inserts a new size-one dimension into an array, similar to NumPy's `None` or `newaxis`. It is equivalent to calling `expandedDimensions`.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/Organization/indexing.md#_snippet_5

LANGUAGE: swift
CODE:
```
// python: array[None]
array[.newAxis]
```

----------------------------------------

TITLE: C++ fmt Library Range Formatting
DESCRIPTION: Demonstrates how to use `fmt::format` with range types like `std::vector`. It shows how to apply different format specifiers to elements within a range, including default printing, hexadecimal representation, and character-to-integer conversion, by providing an `underlying_spec`.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/doc/syntax.rst#_snippet_24

LANGUAGE: C++
CODE:
```
fmt::format("{}", std::vector{10, 20, 30});
// Result: [10, 20, 30]
```

LANGUAGE: C++
CODE:
```
fmt::format("{::#x}", std::vector{10, 20, 30});
// Result: [0xa, 0x14, 0x1e]
```

LANGUAGE: C++
CODE:
```
fmt::format("{}", vector{'h', 'e', 'l', 'l', 'o'});
// Result: ['h', 'e', 'l', 'l', 'o']
```

LANGUAGE: C++
CODE:
```
fmt::format("{::}", vector{'h', 'e', 'l', 'l', 'o'});
// Result: [h, e, l, l, o]
```

LANGUAGE: C++
CODE:
```
fmt::format("{::d}", vector{'h', 'e', 'l', 'l', 'o'});
// Result: [104, 101, 108, 108, 111]
```

----------------------------------------

TITLE: Directly Sort MLXArray (Swift)
DESCRIPTION: Illustrates how to use the `sort` function to directly produce a new MLX array that is sorted. This method returns the sorted array without needing to apply indices.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/Organization/sorting.md#_snippet_1

LANGUAGE: swift
CODE:
```
// array with values in random order
let array = MLXRandom.randInt(0 ..< 100, [10])

// the array in sorted order
let sorted = sort(array)
```

----------------------------------------

TITLE: Format Specifier Alignment Options
DESCRIPTION: Describes the meaning of various alignment options ('<', '>', '^') within format specifications.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/doc/syntax.rst#_snippet_3

LANGUAGE: APIDOC
CODE:
```
Option  | Meaning
--------|----------------------------------------------------------
'<'     | Forces the field to be left-aligned within the available
        | space (this is the default for most objects).
'>'     | Forces the field to be right-aligned within the
        | available space (this is the default for numbers).
'^'     | Forces the field to be centered within the available
        | space.
```

----------------------------------------

TITLE: MLX Swift Ellipsis Operator
DESCRIPTION: Explains the `ellipsis` operator in MLX Swift, used to consume all available axes with full range slices, analogous to Python's `...`. It provides examples of equivalent indexing expressions.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/Organization/indexing.md#_snippet_6

LANGUAGE: swift
CODE:
```
let array = MLXArray.ones([3, 4, 5, 6])

// the following groups of expressions are all equivalent

// python: array[..., 4]
array[.ellipsis, 4]
array[0..., 0..., 0..., 4]

// python: array[2, ...]
array[2, .ellipsis]
array[2, 0..., 0..., 0...]

// python: array[2, ..., 4]
array[2, .ellipsis, 4]
array[2, 0..., 0..., 4]
```

----------------------------------------

TITLE: Install fmt Library using Conda
DESCRIPTION: Provides the command to install the fmt library on Linux, macOS, and Windows using the Conda package manager from the conda-forge channel. This is a straightforward way to get fmt installed in a Conda environment.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/doc/usage.rst#_snippet_16

LANGUAGE: Conda
CODE:
```
conda install -c conda-forge fmt
```

----------------------------------------

TITLE: C++ fmt Library Type-Specific Formatting (Chrono)
DESCRIPTION: Illustrates how to format `std::tm` (time) objects using `fmt::print` with specific format specifiers for date and time components. This requires including the `<fmt/chrono.h>` header to enable chrono-specific formatting capabilities.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/doc/syntax.rst#_snippet_31

LANGUAGE: C++
CODE:
```
#include <fmt/chrono.h>

auto t = tm();
t.tm_year = 2010 - 1900;
t.tm_mon = 7;
t.tm_mday = 4;
t.tm_hour = 12;
t.tm_min = 15;
t.tm_sec = 58;
fmt::print("{:%Y-%m-%d %H:%M:%S}", t);
// Prints: 2010-08-04 12:15:58
```

----------------------------------------

TITLE: MLXArray Complex Number Initializers in Swift
DESCRIPTION: Provides initializers for constructing MLXArray instances representing complex numbers from real and imaginary parts.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/Organization/initialization.md#_snippet_10

LANGUAGE: APIDOC
CODE:
```
MLXArray Complex Initializers:
  - MLXArray/init(real:imaginary:)
  - MLXArray/init(_:)-6iii5
```

----------------------------------------

TITLE: Using Positional Arguments in fmt::print
DESCRIPTION: Shows how to use positional arguments in the format string, allowing reordering of arguments for localization or clarity, similar to Python's format string syntax.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/doc/index.rst#_snippet_4

LANGUAGE: C++
CODE:
```
fmt::print("I'd rather be {1} than {0}.", "right", "happy");
```

----------------------------------------

TITLE: Module Filter Functions for `filter:` Parameter
DESCRIPTION: API documentation for predefined functions usable as the `filter:` parameter in methods like `Module/filterMap(filter:map:isLeaf:)`.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLXNN/Documentation.docc/Module.md#_snippet_5

LANGUAGE: APIDOC
CODE:
```
Module Filter Functions:
- filterAll
- filterLocalParameters
- filterOther
- filterTrainableParameters
- filterValidChild
- filterValidParameters
```

----------------------------------------

TITLE: Build Google Test Library with CMake
DESCRIPTION: This CMake script compiles the Google Test library from its source files into a static library. It ensures C++11 compliance, links against system threads if available, and applies specific compiler definitions to manage warnings and deprecations, especially for Microsoft Visual C++ (MSVC) and Clang on Windows.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/test/gtest/CMakeLists.txt#_snippet_0

LANGUAGE: CMake
CODE:
```
# ------------------------------------------------------------------------------
# Build the google test library

# We compile Google Test ourselves instead of using pre-compiled libraries. See
# the Google Test FAQ "Why is it not recommended to install a pre-compiled copy
# of Google Test (for example, into /usr/local)?" at
# http://code.google.com/p/googletest/wiki/FAQ for more details.
add_library(gtest STATIC gmock-gtest-all.cc gmock/gmock.h gtest/gtest.h
                         gtest/gtest-spi.h)
target_compile_definitions(gtest PUBLIC GTEST_HAS_STD_WSTRING=1)
target_include_directories(gtest SYSTEM PUBLIC .)
target_compile_features(gtest PUBLIC cxx_std_11)

find_package(Threads)
if(Threads_FOUND)
  target_link_libraries(gtest ${CMAKE_THREAD_LIBS_INIT})
else()
  target_compile_definitions(gtest PUBLIC GTEST_HAS_PTHREAD=0)
endif()

if(MSVC)
  # Disable MSVC warnings of _CRT_INSECURE_DEPRECATE functions.
  target_compile_definitions(gtest PRIVATE _CRT_SECURE_NO_WARNINGS)
  if(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
    # Disable MSVC warnings of POSIX functions.
    target_compile_options(gtest PUBLIC -Wno-deprecated-declarations)
  endif()
endif()

# Silence MSVC tr1 deprecation warning in gmock.
target_compile_definitions(gtest
                           PUBLIC _SILENCE_TR1_NAMESPACE_DEPRECATION_WARNING=1)
```

----------------------------------------

TITLE: MLX Swift API: var Function
DESCRIPTION: Documents the API path and signature for the `var` (variance) function in MLX Swift, used for computing the variance of array elements.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/Articles/converting-python.md#_snippet_8

LANGUAGE: APIDOC
CODE:
```
Function: var
Path: MLX/variance(_:axes:keepDims:ddof:stream:)
```

----------------------------------------

TITLE: General Utility Functions in fmt Library
DESCRIPTION: The {fmt} library provides various utility functions for common formatting tasks, including pointer conversion, underlying enum value retrieval, string conversion, and joining ranges or iterators with a separator.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/doc/api.rst#_snippet_18

LANGUAGE: APIDOC
CODE:
```
fmt::ptr(T p) -> const void*
```

LANGUAGE: APIDOC
CODE:
```
fmt::ptr(const std::unique_ptr<T, Deleter> &p) -> const void*
```

LANGUAGE: APIDOC
CODE:
```
fmt::ptr(const std::shared_ptr<T> &p) -> const void*
```

LANGUAGE: APIDOC
CODE:
```
fmt::underlying(Enum e) -> typename std::underlying_type<Enum>::type
```

LANGUAGE: APIDOC
CODE:
```
fmt::to_string(const T &value) -> std::string
```

LANGUAGE: APIDOC
CODE:
```
fmt::join(Range &&range, string_view sep) -> join_view<detail::iterator_t<Range>, detail::sentinel_t<Range>>
```

LANGUAGE: APIDOC
CODE:
```
fmt::join(It begin, Sentinel end, string_view sep) -> join_view<It, Sentinel>
```

LANGUAGE: APIDOC
CODE:
```
fmt::group_digits(T value) -> group_digits_view<T>
```

----------------------------------------

TITLE: Set Default CMake Build Type to Release
DESCRIPTION: This snippet sets the default `CMAKE_BUILD_TYPE` to `Release`. It is crucial to place this command before the `project()` command in CMakeLists.txt, as the `project()` command can potentially override `CMAKE_BUILD_TYPE` if it's not already defined.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/CMakeLists.txt#_snippet_6

LANGUAGE: CMake
CODE:
```
# Set the default CMAKE_BUILD_TYPE to Release. This should be done before the
# project command since the latter can set CMAKE_BUILD_TYPE itself (it does so
```

----------------------------------------

TITLE: Configuring CMake Module Path and Including Utilities
DESCRIPTION: This snippet extends the `CMAKE_MODULE_PATH` to include a custom 'support/cmake' directory, allowing CMake to find additional modules. It then includes standard CMake modules `CheckCXXCompilerFlag` and `JoinPaths`, which provide utility functions for compiler feature checks and path manipulation, respectively.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/CMakeLists.txt#_snippet_15

LANGUAGE: CMake
CODE:
```
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH}
                      "${CMAKE_CURRENT_SOURCE_DIR}/support/cmake")

include(CheckCXXCompilerFlag)
include(JoinPaths)
```

----------------------------------------

TITLE: Global Logical Functions for MLXArray API Reference
DESCRIPTION: List of global logical functions that operate on MLXArray, providing equivalents to instance methods and additional utilities like 'where', 'logicalAnd', and 'logicalNot'.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/Organization/logical.md#_snippet_4

LANGUAGE: APIDOC
CODE:
```
Logical Free Functions:
  all(_:axes:keepDims:stream:)
  allClose(_:_:rtol:atol:equalNaN:stream:)
  any(_:axes:keepDims:stream:)
  arrayEqual(_:_:equalNAN:stream:)
  equal(_:_:stream:)
  greater(_:_:stream:)
  greaterEqual(_:_:stream:)
  isClose(_:_:rtol:atol:equalNaN:stream:)
  less(_:_:stream:)
  lessEqual(_:_:stream:)
  logicalAnd(_:_:stream:)
  logicalNot(_:stream:)
  logicalOr(_:_:stream:)
  notEqual(_:_:stream:)
  where(_:_:_:stream:)
```

----------------------------------------

TITLE: MLXArray Instance Logical Operators API Reference
DESCRIPTION: Comprehensive list of logical operators available as instance methods on MLXArray, including comparison and boolean operators.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/Organization/logical.md#_snippet_2

LANGUAGE: APIDOC
CODE:
```
MLXArray Operators:
  .!(_:)
  .==(_:_:)-56m0a
  .==(_:_:)-79hbc
  .!=(_:_:)-mbw0
  .!=(_:_:)-gkdj
  .<(_:_:)-9rzup
  .<(_:_:)-54ivt
  .<=(_:_:)-2a0s9
  .<=(_:_:)-6vb92
  .>(_:_:)-fwi1
  .>(_:_:)-2v86b
  .>=(_:_:)-2gqml
  .>=(_:_:)-6zxj9
  .&&(_:_:) (Logical AND)
  .||(_:_:) (Logical OR)
```

----------------------------------------

TITLE: MLXArray Instance Logical Functions API Reference
DESCRIPTION: List of logical functions available as instance methods on MLXArray, such as 'all', 'any', 'allClose', and 'arrayEqual'.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/Organization/logical.md#_snippet_3

LANGUAGE: APIDOC
CODE:
```
MLXArray Logical Functions:
  all(axes:keepDims:stream:)
  any(axes:keepDims:stream:)
  allClose(_:rtol:atol:equalNaN:stream:)
  arrayEqual(_:equalNAN:stream:)
```

----------------------------------------

TITLE: Date and Time Format Specifiers Reference
DESCRIPTION: This section provides a reference for various single-character format specifiers used in date and time formatting. Each entry describes the specifier's purpose, its output format, and any associated modified commands that produce locale-specific or alternative representations. Exceptions for unavailable information are also noted.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/doc/syntax.rst#_snippet_23

LANGUAGE: APIDOC
CODE:
```
Format Specifiers:
  't': A horizontal-tab character.
  'T': Equivalent to %H:%M:%S.
  'u': The ISO weekday as a decimal number (1-7), where Monday is 1. The modified command %Ou produces the locale's alternative representation.
  'U': The week number of the year as a decimal number. The first Sunday of the year is the first day of week 01. Days of the same year prior to that are in week 00. If the result is a single digit, it is prefixed with 0. The modified command %OU produces the locale's alternative representation.
  'V': The ISO week-based week number as a decimal number. If the result is a single digit, it is prefixed with 0. The modified command %OV produces the locale's alternative representation.
  'w': The weekday as a decimal number (0-6), where Sunday is 0. The modified command %Ow produces the locale's alternative representation.
  'W': The week number of the year as a decimal number. The first Monday of the year is the first day of week 01. Days of the same year prior to that are in week 00. If the result is a single digit, it is prefixed with 0. The modified command %OW produces the locale's alternative representation.
  'x': The date representation, e.g. "11/12/55". The modified command %Ex produces the locale's alternate date representation.
  'X': The time representation, e.g. "10:04:00". The modified command %EX produces the locale's alternate time representation.
  'y': The last two decimal digits of the year. If the result is a single digit it is prefixed by 0. The modified command %Oy produces the locale's alternative representation. The modified command %Ey produces the locale's alternative representation of offset from %EC (year only).
  'Y': The year as a decimal number. If the result is less than four digits it is left-padded with 0 to four digits. The modified command %EY produces the locale's alternative full year representation.
  'z': The offset from UTC in the ISO 8601:2004 format. For example -0430 refers to 4 hours 30 minutes behind UTC. If the offset is zero, +0000 is used. The modified commands %Ez and %Oz insert a : between the hours and minutes: -04:30. If the offset information is not available, an exception of type format_error is thrown.
  'Z': The time zone abbreviation. If the time zone abbreviation is not
```

----------------------------------------

TITLE: Link to Installed fmt Library with CMake
DESCRIPTION: CMake commands to find an already installed version of the fmt library and link it to a specific target in your project.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/doc/usage.rst#_snippet_6

LANGUAGE: CMake
CODE:
```
find_package(fmt)
target_link_libraries(<your-target> fmt::fmt)
```

----------------------------------------

TITLE: Format C++ Standard Library Variants with fmt/std.h
DESCRIPTION: Shows how to format std::variant and std::monostate types using fmt/std.h. Formatting std::variant requires all its alternatives to be formattable and the __cpp_lib_variant feature.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/doc/api.rst#_snippet_29

LANGUAGE: C++
CODE:
```
#include <fmt/std.h>

std::variant<char, float> v0{'x'};
// Prints "variant('x')"
fmt::print("{}", v0);

std::variant<std::monostate, char> v1;
// Prints "variant(monostate)"
```

----------------------------------------

TITLE: Floating-Point Number Formatting Presentation Types
DESCRIPTION: Defines the single-character type specifiers used to format floating-point values. These types control the notation (hexadecimal, scientific, fixed-point) and case for special values like NaN and infinity, as well as precision handling for general formats.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/doc/syntax.rst#_snippet_12

LANGUAGE: APIDOC
CODE:
```
Floating-Point Presentation Types:
  'a': Hexadecimal floating point format. Prints the number in base 16 with prefix "0x" and lower-case letters for digits above 9. Uses 'p' to indicate the exponent.
  'A': Same as 'a' except it uses upper-case letters for the prefix, digits above 9 and to indicate the exponent.
  'e': Exponent notation. Prints the number in scientific notation using the letter 'e' to indicate the exponent.
  'E': Exponent notation. Same as 'e' except it uses an upper-case 'E' as the separator character.
  'f': Fixed point. Displays the number as a fixed-point number.
  'F': Fixed point. Same as 'f', but converts nan to NAN and inf to INF.
  'g': General format. For a given precision p >= 1, this rounds the number to p significant digits and then formats the result in either fixed-point format or in scientific notation, depending on its magnitude. A precision of 0 is treated as equivalent to a precision of 1.
  'G': General format. Same as 'g' except switches to 'E' if the number gets too large. The representations of infinity and NaN are uppercased, too.
```

----------------------------------------

TITLE: C++ fmt Library Sign Specification
DESCRIPTION: Demonstrates how to control the display of signs for numeric values in `fmt::format`. It shows options to always display the sign (`+`), display a space for positive numbers (` `), or only display the minus sign for negative numbers (`-`), similar to `printf`'s `+f`, `-f`, and ` f` specifiers.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/doc/syntax.rst#_snippet_28

LANGUAGE: C++
CODE:
```
fmt::format("{:+f}; {:+f}", 3.14, -3.14);  // show it always
// Result: "+3.140000; -3.140000"
```

LANGUAGE: C++
CODE:
```
fmt::format("{: f}; {: f}", 3.14, -3.14);  // show a space for positive numbers
// Result: " 3.140000; -3.140000"
```

LANGUAGE: C++
CODE:
```
fmt::format("{:-f}; {:-f}", 3.14, -3.14);  // show only the minus -- same as '{:f}; {:f}'
// Result: "3.140000; -3.140000"
```

----------------------------------------

TITLE: MLX Swift API: tril Function
DESCRIPTION: Documents the API path and signature for the `tril` function in MLX Swift, used to extract the lower triangular part of a matrix.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/Articles/converting-python.md#_snippet_6

LANGUAGE: APIDOC
CODE:
```
Function: tril
Path: MLX/tril(_:k:stream:)
```

----------------------------------------

TITLE: MLX Swift API: triu Function
DESCRIPTION: Documents the API path and signature for the `triu` function in MLX Swift, used to extract the upper triangular part of a matrix.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/Articles/converting-python.md#_snippet_7

LANGUAGE: APIDOC
CODE:
```
Function: triu
Path: MLX/triu(_:k:stream:)
```

----------------------------------------

TITLE: Replacement Field Grammar
DESCRIPTION: Defines the formal grammar for replacement fields within format strings, including argument IDs and format specifications.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/doc/syntax.rst#_snippet_1

LANGUAGE: APIDOC
CODE:
```
replacement_field: "{" [`arg_id`] [":" (`format_spec` | `chrono_format_spec`)] "}"
arg_id: `integer` | `identifier`
integer: `digit`+
digit: "0"..."9"
identifier: `id_start` `id_continue`*
id_start: "a"..."z" | "A"..."Z" | "_"
id_continue: `id_start` | `digit`
```

----------------------------------------

TITLE: Retrieve and Display Target's CUDA Standard Properties in CMake
DESCRIPTION: This snippet demonstrates how to retrieve the `CUDA_STANDARD` and `CUDA_STANDARD_REQUIRED` properties from a CMake target using `get_target_property`. The retrieved values are then displayed to the console using `message(STATUS)` for debugging or verification purposes.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/test/cuda-test/CMakeLists.txt#_snippet_3

LANGUAGE: CMake
CODE:
```
get_target_property(IN_USE_CUDA_STANDARD fmt-in-cuda-test CUDA_STANDARD)
message(STATUS "cuda_standard:          ${IN_USE_CUDA_STANDARD}")

get_target_property(IN_USE_CUDA_STANDARD_REQUIRED fmt-in-cuda-test
                    CUDA_STANDARD_REQUIRED)
message(STATUS "cuda_standard_required: ${IN_USE_CUDA_STANDARD_REQUIRED}")
```

----------------------------------------

TITLE: Named Arguments with C++11 User-Defined Literals
DESCRIPTION: Presents an alternative, more concise syntax for named arguments using C++11 user-defined literals with the `_a` suffix, available when the compiler supports this feature.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/doc/index.rst#_snippet_6

LANGUAGE: C++
CODE:
```
using namespace fmt::literals;
fmt::print("Hello, {name}! The answer is {number}. Goodbye, {name}.",
             "name"_a="World", "number"_a=42);
```

----------------------------------------

TITLE: MLX Swift Cumulative Free Functions
DESCRIPTION: Provides free functions in MLX Swift for cumulative operations such as cumulative maximum, minimum, product, and sum along specified axes.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/free-functions.md#_snippet_2

LANGUAGE: APIDOC
CODE:
```
cummax(_:axis:reverse:inclusive:stream:)
cummax(_:reverse:inclusive:stream:)
cummin(_:axis:reverse:inclusive:stream:)
cummin(_:reverse:inclusive:stream:)
cumprod(_:axis:reverse:inclusive:stream:)
cumprod(_:reverse:inclusive:stream:)
cumsum(_:axis:reverse:inclusive:stream:)
cumsum(_:reverse:inclusive:stream:)
```

----------------------------------------

TITLE: API for Compile-Time Format String Checks in fmt
DESCRIPTION: This section outlines the API elements related to compile-time format string checks in the {fmt} library. These checks are enabled by default with C++20 consteval and can be used with FMT_STRING on older compilers. It includes the basic_format_string class, format_string typedef, and the runtime function for handling runtime format strings.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/doc/api.rst#_snippet_4

LANGUAGE: APIDOC
CODE:
```
Class: fmt::basic_format_string
  Members: (all public members)

Typedef: fmt::format_string
  Alias for: fmt::basic_format_string

Function: fmt::runtime
  Signature: string_view
  Returns: runtime_format_string<>
```

----------------------------------------

TITLE: Initialize MLXArray with Complex Values in Swift
DESCRIPTION: Demonstrates how to create MLXArray instances that support complex numbers (DType.complex64) using Swift-Numerics' Complex type, including combining real and imaginary parts from separate arrays.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/Organization/initialization.md#_snippet_6

LANGUAGE: Swift
CODE:
```
let c1 = MLXArray(Complex(0, 1))
let c2 = MLXArray(real: 0, imaginary: 1)
```

LANGUAGE: Swift
CODE:
```
let c3 = MLXArray([Complex(2, 7), Complex(3, 8), Complex(4, 9)])
```

LANGUAGE: Swift
CODE:
```
let r = MLXRandom.uniform(0.0 ..< 1.0, [100, 100])
let i = MLXRandom.uniform(0.0 ..< 1.0, [100, 100])

// dtype is .complex64
let c = r + i.asImaginary()
```

----------------------------------------

TITLE: Precision Option for Numeric and Non-Numeric Types
DESCRIPTION: The 'precision' option controls the number of digits for floating-point values or the maximum field size for non-numeric types. It is not allowed for integer, character, Boolean, and pointer values.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/doc/syntax.rst#_snippet_7

LANGUAGE: APIDOC
CODE:
```
Syntax: <precision>
  For floating-point values ('f', 'F'):
    Indicates how many digits should be displayed after the decimal point.
  For floating-point values ('g', 'G'):
    Indicates how many digits should be displayed before and after the decimal point.
  For non-number types:
    Indicates the maximum field size (how many characters will be used from the field content).
  Restrictions:
    Not allowed for integer, character, Boolean, and pointer values.
    C string must be null-terminated even if precision is specified.
```

----------------------------------------

TITLE: Build fmt as a Shared Library with CMake
DESCRIPTION: CMake command to configure the fmt library to be built as a shared library instead of a static library.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/doc/usage.rst#_snippet_3

LANGUAGE: CMake
CODE:
```
cmake -DBUILD_SHARED_LIBS=TRUE ...
```

----------------------------------------

TITLE: Xcode Internal Inconsistency Error Message
DESCRIPTION: This snippet displays an example of an internal inconsistency error message that may occur during the build process in Xcode. This specific error indicates a problem with target activity messages and often requires workarounds like restarting Xcode or cleaning the build folder.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/troubleshooting.md#_snippet_3

LANGUAGE: Log
CODE:
```
error: Internal inconsistency error: received multiple target ended messages for target ID '5' or received target ended message but did not receive corresponding target started message, while retrieving parent activity in taskStarted message.
```

----------------------------------------

TITLE: 'd' Format Specifier
DESCRIPTION: The day of month as a decimal number. If the result is a single decimal digit, it is prefixed with 0. The modified command %Od produces the locale's alternative representation.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/doc/syntax.rst#_snippet_18

LANGUAGE: APIDOC
CODE:
```
d: Day of month as decimal. Prefixed with 0 if single digit. Modified by %Od.
```

----------------------------------------

TITLE: Configuring Pedantic Compiler Flags for GNU C++
DESCRIPTION: This CMake block defines a comprehensive set of pedantic and warning flags for the GNU C++ compiler (GCC). It includes common warnings like `-Wall`, `-Wextra`, and `-pedantic`, and conditionally adds more specific warnings based on the GCC version, ensuring strict code quality checks. It also sets `-Werror` to treat warnings as errors.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/CMakeLists.txt#_snippet_17

LANGUAGE: CMake
CODE:
```
if(CMAKE_CXX_COMPILER_ID MATCHES "GNU")
  set(PEDANTIC_COMPILE_FLAGS
      -pedantic-errors
      -Wall
      -Wextra
      -pedantic
      -Wold-style-cast
      -Wundef
      -Wredundant-decls
      -Wwrite-strings
      -Wpointer-arith
      -Wcast-qual
      -Wformat=2
      -Wmissing-include-dirs
      -Wcast-align
      -Wctor-dtor-privacy
      -Wdisabled-optimization
      -Winvalid-pch
      -Woverloaded-virtual
      -Wconversion
      -Wundef
      -Wno-ctor-dtor-privacy
      -Wno-format-nonliteral)
  if(NOT CMAKE_CXX_COMPILER_VERSION VERSION_LESS 4.6)
    set(PEDANTIC_COMPILE_FLAGS ${PEDANTIC_COMPILE_FLAGS} -Wno-dangling-else
                               -Wno-unused-local-typedefs)
  endif()
  if(NOT CMAKE_CXX_COMPILER_VERSION VERSION_LESS 5.0)
    set(PEDANTIC_COMPILE_FLAGS
        ${PEDANTIC_COMPILE_FLAGS}
        -Wdouble-promotion
        -Wtrampolines
        -Wzero-as-null-pointer-constant
        -Wuseless-cast
        -Wvector-operation-performance
        -Wsized-deallocation
        -Wshadow)
  endif()
  if(NOT CMAKE_CXX_COMPILER_VERSION VERSION_LESS 6.0)
    set(PEDANTIC_COMPILE_FLAGS ${PEDANTIC_COMPILE_FLAGS} -Wshift-overflow=2
                               -Wnull-dereference -Wduplicated-cond)
  endif()
  set(WERROR_FLAG -Werror)
endif()
```

----------------------------------------

TITLE: Using Named Arguments with fmt::arg
DESCRIPTION: Explains how to pass named arguments to `fmt::print` using `fmt::arg`, improving readability and maintainability of format strings, especially for complex messages.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/doc/index.rst#_snippet_5

LANGUAGE: C++
CODE:
```
fmt::print("Hello, {name}! The answer is {number}. Goodbye, {name}.",
             fmt::arg("name", "World"), fmt::arg("number", 42));
```

----------------------------------------

TITLE: Integrate fmt Library as CMake Subdirectory
DESCRIPTION: CMake commands to include the fmt library source directory directly into a project's CMakeLists.txt. The 'EXCLUDE_FROM_ALL' option prevents it from being built by default with 'make' or 'cmake --build .'.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/doc/usage.rst#_snippet_5

LANGUAGE: CMake
CODE:
```
add_subdirectory(fmt)

or

add_subdirectory(fmt EXCLUDE_FROM_ALL)
```

----------------------------------------

TITLE: Install Code Formatting Tools for MLX Swift Contributions
DESCRIPTION: Before contributing to MLX Swift, it's recommended to install `pre-commit` for automated code checks and `swift-format` for Swift code style. `pre-commit` is typically installed via Python's `pip`, while `swift-format` can be installed using Homebrew on macOS.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/CONTRIBUTING.md#_snippet_0

LANGUAGE: Shell
CODE:
```
pip install pre-commit
```

LANGUAGE: Shell
CODE:
```
brew install swift-format
```

----------------------------------------

TITLE: MLX Swift Logical Reduction Free Functions
DESCRIPTION: Documents free functions in MLX Swift for logical reduction operations, such as checking if all or any elements satisfy a condition across specified axes.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/free-functions.md#_snippet_7

LANGUAGE: APIDOC
CODE:
```
all(_:axes:keepDims:stream:)
any(_:axes:keepDims:stream:)
```

----------------------------------------

TITLE: Minimum Field Width Option
DESCRIPTION: The 'width' option defines the minimum field width for the output. Preceding it with '0' enables sign-aware zero-padding for numeric types.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/doc/syntax.rst#_snippet_6

LANGUAGE: APIDOC
CODE:
```
Syntax: <width>
  Description: Decimal integer defining the minimum field width.
  Default: Field width determined by content if not specified.
Zero-padding: '0' prefix
  Description: Enables sign-aware zero-padding for numeric types.
  Placement: Padding placed after the sign or base (if any) but before the digits.
  Example: '+000000120'
  Limitations: Only valid for numeric types; no effect on infinity and NaN.
```

----------------------------------------

TITLE: Initialize MLXArray for Broadcasting Examples
DESCRIPTION: Creates an MLXArray from a range of integers and reshapes it to a 4x3 matrix, serving as a base array for demonstrating broadcasting concepts.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/Articles/broadcasting.md#_snippet_0

LANGUAGE: Swift
CODE:
```
let array = MLXArray(0 ..< 12, [4, 3])
```

----------------------------------------

TITLE: Integer and Boolean Formatting Presentation Types
DESCRIPTION: Defines the single-character type specifiers used to format integer, character, and Boolean values. These types control the base (binary, octal, decimal, hexadecimal) and representation (character, textual boolean). Note that the 'c' type cannot be used with Boolean values, and Booleans default to 'true'/'false' if no type is specified.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/doc/syntax.rst#_snippet_11

LANGUAGE: APIDOC
CODE:
```
Integer Presentation Types:
  'b': Binary format. Outputs the number in base 2. Using the '#' option adds the prefix "0b".
  'B': Binary format. Outputs the number in base 2. Using the '#' option adds the prefix "0B".
  'c': Character format. Outputs the number as a character.
  'd': Decimal integer. Outputs the number in base 10.
  'o': Octal format. Outputs the number in base 8.
  'x': Hex format. Outputs the number in base 16, using lower-case letters for digits above 9. Using the '#' option adds the prefix "0x".
  'X': Hex format. Outputs the number in base 16, using upper-case letters for digits above 9. Using the '#' option adds the prefix "0X".
  none: Same as 'd'.
```

----------------------------------------

TITLE: Available Character Presentation Types
DESCRIPTION: This section lists the available type specifiers for formatting character data.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/doc/syntax.rst#_snippet_10

LANGUAGE: APIDOC
CODE:
```
Type: 'c'
  Meaning: Character format. Default type for characters, may be omitted.
Type: '?'
  Meaning: Debug format. Character is quoted and special characters escaped.
Type: 'none'
  Meaning: Same as 'c'.
```

----------------------------------------

TITLE: fmt Literal-Based Formatting Operator
DESCRIPTION: The `fmt/format.h` header defines user-defined literals, such as `operator""_a()`, which provide a convenient and concise syntax for literal-based formatting operations.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/doc/api.rst#_snippet_17

LANGUAGE: APIDOC
CODE:
```
operator""_a()
```

----------------------------------------

TITLE: Error: Compile-time argument type mismatch for fmt::print to stream with number specifier (:d)
DESCRIPTION: Shows an expected compile-time error when `fmt::print` to a stream (`std::cout`) uses a number specifier (`:d`) with a non-numeric argument (string), specifically in a C++20 `consteval` context.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/test/compile-error-test/CMakeLists.txt#_snippet_13

LANGUAGE: C++
CODE:
```
#ifdef FMT_HAS_CONSTEVAL
  fmt::print(std::cout, "{:d}", "I am not a number");
#else
  #error
#endif
```

----------------------------------------

TITLE: fmt Library: printf-like Formatting Functions
DESCRIPTION: Documents the `printf`-like formatting functions provided by the `fmt/printf.h` header. These functions offer type-safe formatting with POSIX positional arguments and throw exceptions on argument type mismatches, unlike standard C functions.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/doc/api.rst#_snippet_36

LANGUAGE: APIDOC
CODE:
```
printf(string_view fmt, const T&... args) -> int
fprintf(std::FILE *f, const S &fmt, const T&... args) -> int
sprintf(const S&, const T&...)
```

----------------------------------------

TITLE: Module Traversal API
DESCRIPTION: API documentation for methods enabling traversal and inspection of the Module's internal structure, including children, leaf modules, and general items.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLXNN/Documentation.docc/Module.md#_snippet_2

LANGUAGE: APIDOC
CODE:
```
Module Traversal API:
- children()
- filterMap(filter:map:isLeaf:)
- leafModules()
- items()
- visit(modules:)
```

----------------------------------------

TITLE: Use nested_formatter for Struct Members in C++
DESCRIPTION: This snippet illustrates how to use `nested_formatter` to apply formatting to individual members of a custom struct, `point`. It shows how to define a `formatter` that inherits from `nested_formatter<double>` and uses `nested()` to format `x` and `y` coordinates within a combined output.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/doc/api.rst#_snippet_9

LANGUAGE: C++
CODE:
```
#include <fmt/format.h>

struct point {
  double x, y;
};

template <>
struct fmt::formatter<point> : nested_formatter<double> {
  auto format(point p, format_context& ctx) const {
    return write_padded(ctx, [=](auto out) {
      return format_to(out, "({}, {})", nested(p.x), nested(p.y));
    });
  }
};

int main() {
  fmt::print("[{:>20.2f}]", point{1, 2});
}
```

----------------------------------------

TITLE: Mixing UTF-8 with UTF-16/32 in fmt::format
DESCRIPTION: Demonstrates correct usage of `fmt::format` with wide strings (UTF-16/32) when both the format string and argument are wide.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/test/compile-error-test/CMakeLists.txt#_snippet_0

LANGUAGE: C++
CODE:
```
fmt::format(L"{}", L"foo");
```

----------------------------------------

TITLE: Create C++ NS::Array with CoreFoundation
DESCRIPTION: This snippet shows how to create an `NS::Array` instance in C++ using the CoreFoundation framework. It demonstrates allocating a `MTL::AccelerationStructureTriangleGeometryDescriptor` and populating an `NS::Array` with it, highlighting the use of `CFArrayCreate` for container management.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/metal-cpp/README.md#_snippet_11

LANGUAGE: C++
CODE:
```
MTL::AccelerationStructureTriangleGeometryDescriptor* pGeoDescriptor  = MTL::AccelerationStructureTriangleGeometryDescriptor::alloc()->init();
CFTypeRef                                             descriptors[]   = { ( CFTypeRef )( pGeoDescriptor ) };
NS::Array*                                            pGeoDescriptors = ( NS::Array* )( CFArrayCreate( kCFAllocatorDefault, descriptors, SIZEOF_ARRAY( descriptors), &kCFTypeArrayCallBacks ) );

// ...

pGeoDescriptors->release();
```

----------------------------------------

TITLE: Write to a file using fmt::output_file (C++)
DESCRIPTION: Demonstrates efficient file writing using `fmt::output_file` from `<fmt/os.h>`. This method can be significantly faster than `fprintf` for single-threaded file operations.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/README.md#_snippet_6

LANGUAGE: C++
CODE:
```
#include <fmt/os.h>

int main() {
  auto out = fmt::output_file("guide.txt");
  out.print("Don't {}", "Panic");
}
```

----------------------------------------

TITLE: fmt Library: Wide Character (wchar_t) Support
DESCRIPTION: Details the `fmt/xchar.h` header, which provides support for `wchar_t` and other exotic character types, including a character trait struct, wide string view, wide format context, and a utility function for converting values to wide strings.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/doc/api.rst#_snippet_37

LANGUAGE: APIDOC
CODE:
```
fmt::is_char (struct)
fmt::wstring_view (typedef)
fmt::wformat_context (typedef)
fmt::to_wstring(const T &value)
```

----------------------------------------

TITLE: Add fmt Subproject to Meson Build File
DESCRIPTION: Meson build file snippet to declare the fmt subproject and retrieve its dependency object, making it available for linking.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/doc/usage.rst#_snippet_12

LANGUAGE: Meson
CODE:
```
fmt = subproject('fmt')
fmt_dep = fmt.get_variable('fmt_dep')
```

----------------------------------------

TITLE: Compile-Time Error for Wide Character to Narrow String
DESCRIPTION: Shows how the library prevents incorrect formatting of wide characters into narrow strings at compile time, avoiding silent data loss or unexpected numeric output seen with `std::ostream`.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/doc/index.rst#_snippet_9

LANGUAGE: C++
CODE:
```
fmt::format("Cyrillic letter {}", L'\x42e');
```

----------------------------------------

TITLE: fmt::format_to_n_result Struct Reference
DESCRIPTION: Documentation for the fmt::format_to_n_result struct, which is used as the return type for format_to_n functions, providing information about the output iterator and the number of characters written.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/doc/api.rst#_snippet_2

LANGUAGE: APIDOC
CODE:
```
Struct: fmt::format_to_n_result
  Members: (all public members)
```

----------------------------------------

TITLE: Manually Run MLX Swift Code Formatters and Pre-commit Hooks
DESCRIPTION: After installing the necessary tools, you can manually apply Swift formatting to source files using `swift-format` or run all configured `pre-commit` hooks across the entire repository to ensure code quality and adherence to style guidelines.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/CONTRIBUTING.md#_snippet_1

LANGUAGE: Shell
CODE:
```
swift-format -i Source/MLX/*.swift
```

LANGUAGE: Shell
CODE:
```
pre-commit run --all-files
```

----------------------------------------

TITLE: Basic CMake Build Workflow for fmt Library
DESCRIPTION: Steps to set up a build directory, generate native build scripts (e.g., Makefiles or Visual Studio projects), and prepare for compilation of the fmt library using CMake.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/doc/usage.rst#_snippet_0

LANGUAGE: Shell
CODE:
```
mkdir build
cd build
cmake ..
```

----------------------------------------

TITLE: Available String Presentation Types
DESCRIPTION: This section lists the available type specifiers for formatting string data.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/doc/syntax.rst#_snippet_9

LANGUAGE: APIDOC
CODE:
```
Type: 's'
  Meaning: String format. Default type for strings, may be omitted.
Type: '?'
  Meaning: Debug format. String is quoted and special characters escaped.
Type: 'none'
  Meaning: Same as 's'.
```

----------------------------------------

TITLE: fmt Library System Error Reporting Functions
DESCRIPTION: The {fmt} library provides functions for reporting system errors, such as `fmt::system_error` and `fmt::format_system_error`, which can be used to handle errors originating from system calls without relying on `errno`.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/doc/api.rst#_snippet_20

LANGUAGE: APIDOC
CODE:
```
fmt::system_error
```

LANGUAGE: APIDOC
CODE:
```
fmt::format_system_error
```

----------------------------------------

TITLE: fmt System APIs Reference
DESCRIPTION: API documentation for system-related functionalities provided by the fmt library.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/doc/api.rst#_snippet_33

LANGUAGE: APIDOC
CODE:
```
Classes:
  fmt::ostream: Represents an output stream.

Functions:
  fmt::windows_error: Represents a Windows-specific error.
```

----------------------------------------

TITLE: C++ fmt Library Base Conversion
DESCRIPTION: Illustrates how to convert integer values to different bases (decimal, hexadecimal, octal, binary) using `fmt::format`. It also shows how to include prefixes like `0x`, `0`, or `0b` for hexadecimal, octal, and binary representations, respectively, using the `#` specifier.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/doc/syntax.rst#_snippet_29

LANGUAGE: C++
CODE:
```
fmt::format("int: {0:d};  hex: {0:x};  oct: {0:o}; bin: {0:b}", 42);
// Result: "int: 42;  hex: 2a;  oct: 52; bin: 101010"
```

LANGUAGE: C++
CODE:
```
fmt::format("int: {0:d};  hex: {0:#x};  oct: {0:#o};  bin: {0:#b}", 42);
// Result: "int: 42;  hex: 0x2a;  oct: 052;  bin: 0b101010"
```

LANGUAGE: C++
CODE:
```
fmt::format("{:#04x}", 0);
// Result: "0x00"
```

----------------------------------------

TITLE: Formatting a function pointer using fmt::ptr
DESCRIPTION: Demonstrates the correct way to format a function pointer using `fmt::ptr` for `fmt::format`.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/test/compile-error-test/CMakeLists.txt#_snippet_4

LANGUAGE: C++
CODE:
```
void (*f)();
fmt::format("{}", fmt::ptr(f));
```

----------------------------------------

TITLE: Module Map Functions for `map:` Parameter
DESCRIPTION: API documentation for predefined functions useful for building the `map:` parameter in methods like `Module/filterMap(filter:map:isLeaf:)`.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLXNN/Documentation.docc/Module.md#_snippet_7

LANGUAGE: APIDOC
CODE:
```
Module Map Functions:
- mapModule(map:)
- mapOther(map:)
- mapParameters(map:)
```

----------------------------------------

TITLE: Compile-time Format String Optimization with fmt/compile.h
DESCRIPTION: Explains how to use FMT_COMPILE macro or _cf user-defined literal for compile-time parsing and checking of format strings. Includes an example of a custom formatter specialization.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/doc/api.rst#_snippet_30

LANGUAGE: C++
CODE:
```
template <> struct fmt::formatter<point> {
  constexpr auto parse(format_parse_context& ctx);

  template <typename FormatContext>
  auto format(const point& p, FormatContext& ctx) const;
};
```

----------------------------------------

TITLE: Build MLX Swift Example Executables
DESCRIPTION: Defines and builds two example executables, 'example1' and 'tutorial', from their respective Swift source files. Both executables are linked privately against the core MLX library and compiled with the '-parse-as-library' option.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/CMakeLists.txt#_snippet_10

LANGUAGE: CMake
CODE:
```
add_executable(example1
               ${CMAKE_CURRENT_LIST_DIR}/Source/Examples/Example1.swift)
target_link_libraries(example1 PRIVATE MLX)
target_compile_options(example1 PRIVATE -parse-as-library)

add_executable(tutorial
               ${CMAKE_CURRENT_LIST_DIR}/Source/Examples/Tutorial.swift)
target_link_libraries(tutorial PRIVATE MLX)
target_compile_options(tutorial PRIVATE -parse-as-library)
```

----------------------------------------

TITLE: Alternate Form '#' Option for Formatting
DESCRIPTION: The '#' option modifies the conversion output, adding prefixes for integer types and ensuring decimal points for floating-point numbers.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/doc/syntax.rst#_snippet_5

LANGUAGE: APIDOC
CODE:
```
Effect on Integers (binary, octal, hexadecimal):
  Adds prefix "0b" ("0B"), "0", or "0x" ("0X") to the output value.
  Prefix case determined by type specifier case (e.g., 'x' -> "0x", 'X' -> "0X").
Effect on Floating-point numbers:
  Result always contains a decimal-point character, even if no digits follow.
  For 'g' and 'G' conversions, trailing zeros are not removed.
```

----------------------------------------

TITLE: Configure CMake Project and Policies
DESCRIPTION: Sets the minimum required CMake version, defines the project name 'MLXSwift' with supported languages (C, CXX, Swift), includes the FetchContent module for managing external dependencies, and applies a CMake policy to avoid warnings in newer CMake versions.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/CMakeLists.txt#_snippet_0

LANGUAGE: CMake
CODE:
```
cmake_minimum_required(VERSION 3.16)
project(MLXSwift LANGUAGES C CXX Swift)

include(FetchContent)
# Avoid warning about DOWNLOAD_EXTRACT_TIMESTAMP in CMake 3.24:
if(POLICY CMP0135)
  cmake_policy(SET CMP0135 NEW)
endif()
```

----------------------------------------

TITLE: Example: Formatting User-Defined Enum with fmt::format_as
DESCRIPTION: This C++ example demonstrates how to make a user-defined enum (kevin_namespacy::film) formattable using the fmt::format_as function. By returning fmt::underlying(f), the enum's underlying integer value is printed when formatted, simplifying custom type integration.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/doc/api.rst#_snippet_6

LANGUAGE: C++
CODE:
```
#include <fmt/format.h>

namespace kevin_namespacy {
enum class film {
  house_of_cards, american_beauty, se7en = 7
};
auto format_as(film f) { return fmt::underlying(f); }
}

int main() {
  fmt::print("{}\n", kevin_namespacy::film::se7en); // prints "7"
}
```

----------------------------------------

TITLE: Formatting custom type with explicit cast to std::string
DESCRIPTION: Illustrates how to format a custom struct `S` by explicitly casting it to `std::string` before passing to `fmt::format`.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/test/compile-error-test/CMakeLists.txt#_snippet_2

LANGUAGE: C++
CODE:
```
struct S {
  operator std::string() const { return std::string(); }
};
fmt::format("{}", std::string(S()));
```

----------------------------------------

TITLE: C++ fmt Library Locale-Specific Thousands Separator
DESCRIPTION: Demonstrates how to apply locale-specific formatting, specifically using a thousands separator, with `fmt::format`. By providing a `std::locale` object and the `L` format specifier, numbers can be formatted according to the conventions of a specified locale, such as `en_US.UTF-8`.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/doc/syntax.rst#_snippet_32

LANGUAGE: C++
CODE:
```
#include <fmt/format.h>

auto s = fmt::format(std::locale("en_US.UTF-8"), "{:L}", 1234567890);
// s == "1,234,567,890"
```

----------------------------------------

TITLE: FMT_STRING Macro for Legacy Compile-Time Checks
DESCRIPTION: The `FMT_STRING` macro enables compile-time format string checks on older compilers (C++14 or later). When `FMT_ENFORCE_COMPILE_STRING` is defined, functions accepting `FMT_STRING` will enforce these checks, failing compilation with regular strings.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/doc/api.rst#_snippet_25

LANGUAGE: APIDOC
CODE:
```
FMT_STRING
```

----------------------------------------

TITLE: Configure CUDA Project with CMake Versions 3.15 and Higher
DESCRIPTION: This block configures CUDA projects for CMake versions 3.15 and higher, using the 'new' way of handling CUDA. It adds an executable, enables separable compilation, and sets C++14 compile features. For MSVC, it appends specific compile options directly to source files to ensure correct C++ standard propagation for both host and device code.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/test/cuda-test/CMakeLists.txt#_snippet_2

LANGUAGE: CMake
CODE:
```
else()
  add_executable(fmt-in-cuda-test cuda-cpp14.cu cpp14.cc)
  set_target_properties(fmt-in-cuda-test PROPERTIES CUDA_SEPARABLE_COMPILATION
                                                    ON)
  target_compile_features(fmt-in-cuda-test PRIVATE cxx_std_14)
  if(MSVC)
    set_property(
      SOURCE cuda-cpp14.cu
      APPEND
      PROPERTY COMPILE_OPTIONS -Xcompiler /std:c++14 -Xcompiler /Zc:__cplusplus)
    set_property(SOURCE cpp14.cc APPEND PROPERTY COMPILE_OPTIONS /std:c++14
                                                 /Zc:__cplusplus)
  endif()
endif()
```

----------------------------------------

TITLE: Using Custom Allocators with fmt::basic_memory_buffer
DESCRIPTION: This C++ code snippet demonstrates how to specify a custom allocator class as a template argument to `fmt::basic_memory_buffer`, allowing users to control dynamic memory allocation for output buffers.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/doc/api.rst#_snippet_21

LANGUAGE: C++
CODE:
```
using custom_memory_buffer =
  fmt::basic_memory_buffer<char, fmt::inline_buffer_size, custom_allocator>;
```

----------------------------------------

TITLE: Set Cache Variable with Multi-line Docstring
DESCRIPTION: The `set_verbose` function allows setting a CMake cache variable with a docstring that can be constructed from multiple arguments. This improves readability for long documentation strings, especially when `cmake_parse_arguments` is not fully functional (e.g., in CMake 3.4).
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/CMakeLists.txt#_snippet_5

LANGUAGE: CMake
CODE:
```
function(set_verbose)
  # cmake_parse_arguments is broken in CMake 3.4 (cannot parse CACHE) so use
  # list instead.
  list(GET ARGN 0 var)
  list(REMOVE_AT ARGN 0)
  list(GET ARGN 0 val)
  list(REMOVE_AT ARGN 0)
  list(REMOVE_AT ARGN 0)
  list(GET ARGN 0 type)
  list(REMOVE_AT ARGN 0)
  join(doc ${ARGN})
  set(${var}
      ${val}
      CACHE ${type} ${doc})
endfunction()
```

----------------------------------------

TITLE: 'D' Format Specifier
DESCRIPTION: Equivalent to %m/%d/%y, e.g. "11/12/55".
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/doc/syntax.rst#_snippet_19

LANGUAGE: APIDOC
CODE:
```
D: Equivalent to %m/%d/%y. E.g., "11/12/55".
```

----------------------------------------

TITLE: Error: Compile-time argument type mismatch for fmt::print with number specifier (:d)
DESCRIPTION: Shows an expected compile-time error when `fmt::print` uses a number specifier (`:d`) with a non-numeric argument (string), specifically in a C++20 `consteval` context.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/test/compile-error-test/CMakeLists.txt#_snippet_12

LANGUAGE: C++
CODE:
```
#ifdef FMT_HAS_CONSTEVAL
  fmt::print("{:d}", "I am not a number");
#else
  #error
#endif
```

----------------------------------------

TITLE: Chrono Duration and Time Point Format Syntax
DESCRIPTION: Defines the formal syntax for formatting chrono duration and time point types, as well as `std::tm`, using a production list notation. It outlines the components like fill, align, width, precision, chrono_specs, conversion_spec, literal_char, modifier, and chrono_type.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/doc/syntax.rst#_snippet_15

LANGUAGE: APIDOC
CODE:
```
chrono_format_spec: [[`fill`]`align`][`width`]["." `precision`][`chrono_specs`]
chrono_specs: [`chrono_specs`] `conversion_spec` | `chrono_specs` `literal_char`
conversion_spec: "%" [`modifier`] `chrono_type`
literal_char: <a character other than '{', '}' or '%'>
modifier: "E" | "O"
chrono_type: "a" | "A" | "b" | "B" | "c" | "C" | "d" | "D" | "e" | "F" |
             "g" | "G" | "h" | "H" | "I" | "j" | "m" | "M" | "n" | "p" |
             "q" | "Q" | "r" | "R" | "S" | "t" | "T" | "u" | "U" | "V" |
             "w" | "W" | "x" | "X" | "y" | "Y" | "z" | "Z" | "%"
```

----------------------------------------

TITLE: Configure CMake for Optional CUDA Tests
DESCRIPTION: This CMake snippet conditionally enables CUDA tests if `FMT_CUDA_TEST` is true and CUDA is found. It includes logic to find CUDA based on the CMake version (using `find_package` for older versions and `check_language`/`enable_language` for newer ones). If CUDA is found, it adds a `cuda-test` subdirectory and defines a CTest entry for it.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/test/CMakeLists.txt#_snippet_14

LANGUAGE: CMake
CODE:
```
if(${CMAKE_VERSION} VERSION_LESS 3.15)
    find_package(CUDA 9.0)
  else()
    include(CheckLanguage)
    check_language(CUDA)
    if(CMAKE_CUDA_COMPILER)
      enable_language(CUDA OPTIONAL)
      set(CUDA_FOUND TRUE)
    endif()
  endif()

  if(CUDA_FOUND)
    add_subdirectory(cuda-test)
    add_test(NAME cuda-test COMMAND fmt-in-cuda-test)
  endif()
```

----------------------------------------

TITLE: Format Custom Enum with Alignment using fmt::format in C++
DESCRIPTION: This example shows how to use the custom `fmt::formatter<color>` to format an `enum class color` value. It demonstrates applying standard string format specifiers like alignment and width, which are inherited from `formatter<string_view>`.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/doc/api.rst#_snippet_8

LANGUAGE: C++
CODE:
```
fmt::format("{:>10}", color::blue)
```

----------------------------------------

TITLE: Install fmt Library on Unix-like Systems
DESCRIPTION: Command to install the compiled fmt library system-wide on Unix-like operating systems after building.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/doc/usage.rst#_snippet_2

LANGUAGE: Shell
CODE:
```
sudo make install
```

----------------------------------------

TITLE: Configure General Build and Warning Options in CMake
DESCRIPTION: These options control the strictness of the build process. 'FMT_PEDANTIC' enables extra warnings and expensive tests, while 'FMT_WERROR' halts compilation with an error if any compiler warnings are encountered, promoting cleaner code.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/CMakeLists.txt#_snippet_9

LANGUAGE: CMake
CODE:
```
option(FMT_PEDANTIC "Enable extra warnings and expensive tests." OFF)
option(FMT_WERROR "Halt the compilation with an error on compiler warnings."
       OFF)
```

----------------------------------------

TITLE: Create Metal Device
DESCRIPTION: Illustrates how to obtain the default system Metal device across different memory management paradigms in Objective-C and C++. It shows both manual reference counting and automatic reference counting (ARC) approaches, as well as usage with NS::SharedPtr.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/metal-cpp/README.md#_snippet_6

LANGUAGE: objc
CODE:
```
id< MTLDevice > device = MTLCreateSystemDefaultDevice();

// ...
```

LANGUAGE: objc
CODE:
```
id< MTLDevice > device = MTLCreateSystemDefaultDevice();

// ...

[device release];
```

LANGUAGE: cpp
CODE:
```
MTL::Device* pDevice = MTL::CreateSystemDefaultDevice();

// ...

pDevice->release();
```

LANGUAGE: cpp
CODE:
```
NS::SharedPtr< MTL::Device > pDevice = NS::TransferPtr( MTL::CreateSystemDefaultDevice() );

// ...
```

----------------------------------------

TITLE: Link Libraries to a CUDA Target in CMake
DESCRIPTION: This snippet shows how to link a library, specifically `fmt::fmt`, to a CUDA target using `target_link_libraries`. It highlights that `PUBLIC` or other keywords are intentionally omitted, adhering to recommendations found in CMake's `FindCUDA` module documentation regarding `CUDA_LINK_LIBRARIES_KEYWORD`.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/test/cuda-test/CMakeLists.txt#_snippet_4

LANGUAGE: CMake
CODE:
```
target_link_libraries(fmt-in-cuda-test fmt::fmt)
```

----------------------------------------

TITLE: Setting C++ Symbol Visibility Presets in CMake
DESCRIPTION: This CMake block configures C++ symbol visibility settings, specifically when `FMT_MASTER_PROJECT` is enabled. It conditionally sets `CMAKE_CXX_VISIBILITY_PRESET` to 'hidden' for private symbol export and enables `CMAKE_VISIBILITY_INLINES_HIDDEN` to hide symbols of inline functions, optimizing library exports and reducing binary size.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/CMakeLists.txt#_snippet_16

LANGUAGE: CMake
CODE:
```
if(FMT_MASTER_PROJECT AND NOT DEFINED CMAKE_CXX_VISIBILITY_PRESET)
  set_verbose(CMAKE_CXX_VISIBILITY_PRESET hidden CACHE STRING
              "Preset for the export of private symbols")
  set_property(CACHE CMAKE_CXX_VISIBILITY_PRESET PROPERTY STRINGS hidden
                                                          default)
endif()

if(FMT_MASTER_PROJECT AND NOT DEFINED CMAKE_VISIBILITY_INLINES_HIDDEN)
  set_verbose(
    CMAKE_VISIBILITY_INLINES_HIDDEN ON CACHE BOOL
    "Whether to add a compile flag to hide symbols of inline functions")
endif()
```

----------------------------------------

TITLE: metal-cpp nullptr Method Call Behavior
DESCRIPTION: Explains that calling methods on `nullptr` objects in metal-cpp is legal and results in a no-operation (NOP), similar to Objective-C. It cautions against assuming object validity based solely on the absence of a crash.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/metal-cpp/README.md#_snippet_3

LANGUAGE: APIDOC
CODE:
```
nullptr:
  Behavior: Legal to call any method (e.g., `retain()`, `release()`) on `nullptr` "objects".
  Effect: Equivalent to a NOP, despite incurring function call overhead.
  Caution: Do not assume object validity if a method call on a pointer does not result in a crash.
```

----------------------------------------

TITLE: Error: Formatting many arguments including an unformattable type
DESCRIPTION: Illustrates an expected compile-time error when `fmt::format` is called with a large number of arguments, one of which is an unformattable custom type `E`.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/test/compile-error-test/CMakeLists.txt#_snippet_6

LANGUAGE: C++
CODE:
```
struct E {};
fmt::format("", 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, E());
```

----------------------------------------

TITLE: Extracting and Displaying Project Version in CMake
DESCRIPTION: This snippet demonstrates how to extract major, minor, and patch version components using CMake's `math` command and then join them into a formatted version string. It concludes by displaying the final version using `message(STATUS)`.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/CMakeLists.txt#_snippet_13

LANGUAGE: CMake
CODE:
```
math(EXPR CPACK_PACKAGE_VERSION_MAJOR ${CMAKE_MATCH_1})
math(EXPR CPACK_PACKAGE_VERSION_MINOR ${CMAKE_MATCH_2})
math(EXPR CPACK_PACKAGE_VERSION_PATCH ${CMAKE_MATCH_3})
join(FMT_VERSION ${CPACK_PACKAGE_VERSION_MAJOR}.${CPACK_PACKAGE_VERSION_MINOR}.
     ${CPACK_PACKAGE_VERSION_PATCH})
message(STATUS "Version: ${FMT_VERSION}")
```

----------------------------------------

TITLE: Error: Formatting custom type without explicit cast to std::string
DESCRIPTION: Shows an expected compile-time error when attempting to format a custom struct `S` directly with `fmt::format` without an explicit conversion to `std::string`.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/test/compile-error-test/CMakeLists.txt#_snippet_3

LANGUAGE: C++
CODE:
```
struct S {
  operator std::string() const { return std::string(); }
};
fmt::format("{}", S());
```

----------------------------------------

TITLE: Error: Formatting a function pointer directly
DESCRIPTION: Shows an expected compile-time error when attempting to format a function pointer directly with `fmt::format` without using `fmt::ptr`.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/test/compile-error-test/CMakeLists.txt#_snippet_5

LANGUAGE: C++
CODE:
```
void (*f)();
fmt::format("{}", f);
```

----------------------------------------

TITLE: Error: Compile-time argument type mismatch for number specifier (:d)
DESCRIPTION: Shows an expected compile-time error when `fmt::format` uses a number specifier (`:d`) with a non-numeric argument (string), specifically in a C++20 `consteval` context.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/test/compile-error-test/CMakeLists.txt#_snippet_11

LANGUAGE: C++
CODE:
```
#ifdef FMT_HAS_CONSTEVAL
  fmt::format("{:d}", "I am not a number");
#else
  #error
#endif
```

----------------------------------------

TITLE: Compile-time argument type check for number specifier (:d)
DESCRIPTION: Demonstrates `fmt::format` with a number specifier (`:d`) and an integer argument, expected to compile successfully when `FMT_HAS_CONSTEVAL` is defined (C++20 context).
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/test/compile-error-test/CMakeLists.txt#_snippet_10

LANGUAGE: C++
CODE:
```
#ifdef FMT_HAS_CONSTEVAL
  fmt::format("{:d}", 42);
#endif
```

----------------------------------------

TITLE: Pointer Formatting Presentation Types
DESCRIPTION: Details the available presentation types for formatting pointers, specifically `'p'` and `none`, which both represent the standard pointer format. The `'p'` type is the default and can be omitted.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/doc/syntax.rst#_snippet_14

LANGUAGE: APIDOC
CODE:
```
Type: 'p'
Meaning: Pointer format. This is the default type for pointers and may be omitted.

Type: none
Meaning: The same as 'p'.
```

----------------------------------------

TITLE: Configure nlohmann/json Build Options
DESCRIPTION: This snippet defines various build options for the nlohmann/json library, controlling features like test building, CI targets, diagnostic messages, global UDLs, implicit conversions, enum serialization, legacy comparison, installation, and header usage (single vs. multiple). Initial values are set based on CMake version and main project status.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/json/CMakeLists.txt#_snippet_2

LANGUAGE: CMake
CODE:
```
# VERSION_GREATER_EQUAL is not available in CMake 3.1
if(${MAIN_PROJECT} AND (${CMAKE_VERSION} VERSION_EQUAL 3.13
                        OR ${CMAKE_VERSION} VERSION_GREATER 3.13))
  set(JSON_BuildTests_INIT ON)
else()
  set(JSON_BuildTests_INIT OFF)
endif()
option(JSON_BuildTests "Build the unit tests when BUILD_TESTING is enabled."
       ${JSON_BuildTests_INIT})
option(JSON_CI "Enable CI build targets." OFF)
option(JSON_Diagnostics "Use extended diagnostic messages." OFF)
option(JSON_GlobalUDLs
       "Place use-defined string literals in the global namespace." ON)
option(JSON_ImplicitConversions "Enable implicit conversions." ON)
option(JSON_DisableEnumSerialization
       "Disable default integer enum serialization." OFF)
option(JSON_LegacyDiscardedValueComparison
       "Enable legacy discarded value comparison." OFF)
option(JSON_Install "Install CMake targets during install step."
       ${MAIN_PROJECT})
option(JSON_MultipleHeaders "Use non-amalgamated version of the library." ON)
option(JSON_SystemInclude "Include as system headers (skip for clang-tidy)."
       OFF)

if(JSON_CI)
  include(ci)
endif()
```

----------------------------------------

TITLE: Manage Memory with C++ NS::AutoreleasePool
DESCRIPTION: This snippet demonstrates basic memory management using `NS::AutoreleasePool` in C++. It initializes an autorelease pool, creates an `NS::String`, prints its content, and then explicitly releases the pool to deallocate objects.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/metal-cpp/README.md#_snippet_9

LANGUAGE: C++
CODE:
```
NS::AutoreleasePool* pPool   = NS::AutoreleasePool::alloc()->init();
NS::String*          pString = NS::String::string( "Hello World", NS::ASCIIStringEncoding );

printf( "pString = \"%s\"\n", pString->cString( NS::ASCIIStringEncoding ) );

pPool->release();
```

----------------------------------------

TITLE: Define fmt::formatter for Custom Enum Type in C++
DESCRIPTION: This snippet demonstrates how to define a custom `fmt::formatter` for an `enum class color` by specializing the `formatter` template. It shows inheriting `parse` from `formatter<string_view>` and implementing the `format` method to convert enum values to string representations.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/doc/api.rst#_snippet_7

LANGUAGE: C++
CODE:
```
// color.h:
#include <fmt/core.h>

enum class color {red, green, blue};

template <> struct fmt::formatter<color>: formatter<string_view> {
  // parse is inherited from formatter<string_view>.

  auto format(color c, format_context& ctx) const;
};

// color.cc:
#include "color.h"
#include <fmt/format.h>

auto fmt::formatter<color>::format(color c, format_context& ctx) const {
  string_view name = "unknown";
  switch (c) {
  case color::red:   name = "red"; break;
  case color::green: name = "green"; break;
  case color::blue:  name = "blue"; break;
  }
  return formatter<string_view>::format(name, ctx);
}
```

----------------------------------------

TITLE: Standard Format Specifier Grammar
DESCRIPTION: Defines the formal grammar for standard format specifiers, including fill, alignment, sign, width, precision, and type options.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/doc/syntax.rst#_snippet_2

LANGUAGE: APIDOC
CODE:
```
format_spec: [[`fill`]`align`][`sign`]["#"]["0"][`width`]["." `precision`]["L"][`type`]
fill: <a character other than '{' or '}'>
align: "<" | ">" | "^"
sign: "+" | "-" | " "
width: `integer` | "{" [`arg_id`] "}"
precision: `integer` | "{" [`arg_id`] "}"
type: "a" | "A" | "b" | "B" | "c" | "d" | "e" | "E" | "f" | "F" | "g" | "G" |
    "o" | "p" | "s" | "x" | "X" | "?"
```

----------------------------------------

TITLE: MLX Swift Project CMake Build Configuration
DESCRIPTION: This CMake script defines the build process for an MLX Swift project. It sets the minimum required CMake version, configures shared library building, manages symbol visibility, and conditionally enables Link-Time Optimization (LTO) based on GCC compiler versions. It also includes an external 'fmt' library, defines a shared library (`library-test`), and an executable (`exe-test`), linking them appropriately.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/test/static-export-test/CMakeLists.txt#_snippet_0

LANGUAGE: CMake
CODE:
```
cmake_minimum_required(VERSION 3.8...3.25)

project(fmt-link CXX)

set(BUILD_SHARED_LIBS OFF)
set(CMAKE_VISIBILITY_INLINES_HIDDEN TRUE)
set(CMAKE_CXX_VISIBILITY_PRESET "hidden")

# Broken LTO on GCC 4
if(CMAKE_COMPILER_IS_GNUCXX AND CMAKE_CXX_COMPILER_VERSION VERSION_LESS 5)
  set(BROKEN_LTO ON)
endif()

if(NOT BROKEN_LTO AND CMAKE_VERSION VERSION_GREATER "3.8")
  # CMake 3.9+
  include(CheckIPOSupported)
  check_ipo_supported(RESULT HAVE_IPO)
  if(HAVE_IPO)
    set(CMAKE_INTERPROCEDURAL_OPTIMIZATION TRUE)
  endif()
endif()

add_subdirectory(../.. fmt)
set_property(TARGET fmt PROPERTY POSITION_INDEPENDENT_CODE ON)

add_library(library-test SHARED library.cc)
target_link_libraries(library-test PRIVATE fmt::fmt)

add_executable(exe-test main.cc)
target_link_libraries(exe-test PRIVATE library-test)
```

----------------------------------------

TITLE: Configure and Create Metal Sampler State
DESCRIPTION: Shows how to configure a MTLSamplerDescriptor and create a MTLSamplerState in Objective-C and C++. Examples cover setting address modes, filter types, and argument buffer support, demonstrating both ARC and manual reference counting, and NS::SharedPtr usage.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/metal-cpp/README.md#_snippet_7

LANGUAGE: objc
CODE:
```
MTLSamplerDescriptor* samplerDescriptor = [[MTLSamplerDescriptor alloc] init];

[samplerDescriptor setSAddressMode: MTLSamplerAddressModeRepeat];
[samplerDescriptor setTAddressMode: MTLSamplerAddressModeRepeat];
[samplerDescriptor setRAddressMode: MTLSamplerAddressModeRepeat];
[samplerDescriptor setMagFilter: MTLSamplerMinMagFilterLinear];
[samplerDescriptor setMinFilter: MTLSamplerMinMagFilterLinear];
[samplerDescriptor setMipFilter: MTLSamplerMipFilterLinear];
[samplerDescriptor setSupportArgumentBuffers: YES];

id< MTLSamplerState > samplerState = [device newSamplerStateWithDescriptor:samplerDescriptor];
```

LANGUAGE: objc
CODE:
```
MTLSamplerDescriptor* samplerDescriptor = [[MTLSamplerDescriptor alloc] init];

[samplerDescriptor setSAddressMode: MTLSamplerAddressModeRepeat];
[samplerDescriptor setTAddressMode: MTLSamplerAddressModeRepeat];
[samplerDescriptor setRAddressMode: MTLSamplerAddressModeRepeat];
[samplerDescriptor setMagFilter: MTLSamplerMinMagFilterLinear];
[samplerDescriptor setMinFilter: MTLSamplerMinMagFilterLinear];
[samplerDescriptor setMipFilter: MTLSamplerMipFilterLinear];
[samplerDescriptor setSupportArgumentBuffers: YES];

id< MTLSamplerState > samplerState = [device newSamplerStateWithDescriptor:samplerDescriptor];

[samplerDescriptor release];

// ...

[samplerState release];
```

LANGUAGE: cpp
CODE:
```
MTL::SamplerDescriptor* pSamplerDescriptor = MTL::SamplerDescriptor::alloc()->init();

pSamplerDescriptor->setSAddressMode( MTL::SamplerAddressModeRepeat );
pSamplerDescriptor->setTAddressMode( MTL::SamplerAddressModeRepeat );
pSamplerDescriptor->setRAddressMode( MTL::SamplerAddressModeRepeat );
pSamplerDescriptor->setMagFilter( MTL::SamplerMinMagFilterLinear );
pSamplerDescriptor->setMinFilter( MTL::SamplerMinMagFilterLinear );
pSamplerDescriptor->setMipFilter( MTL::SamplerMipFilterLinear );
pSamplerDescriptor->setSupportArgumentBuffers( true );

MTL::SamplerState* pSamplerState = pDevice->newSamplerState( pSamplerDescriptor );

pSamplerDescriptor->release();

// ...

pSamplerState->release();
```

LANGUAGE: cpp
CODE:
```
NS::SharedPtr< MTL::SamplerDescriptor > pSamplerDescriptor = NS::TransferPtr( MTL::SamplerDescriptor::alloc()->init() );

pSamplerDescriptor->setSAddressMode( MTL::SamplerAddressModeRepeat );
pSamplerDescriptor->setTAddressMode( MTL::SamplerAddressModeRepeat );
pSamplerDescriptor->setRAddressMode( MTL::SamplerAddressModeRepeat );
pSamplerDescriptor->setMagFilter( MTL::SamplerMinMagFilterLinear );
pSamplerDescriptor->setMinFilter( MTL::SamplerMinMagFilterLinear );
pSamplerDescriptor->setMipFilter( MTL::SamplerMipFilterLinear );
pSamplerDescriptor->setSupportArgumentBuffers( true );

NS::SharedPtr< MTL::SamplerState > pSamplerState( pDevice->newSamplerState( pSamplerDescriptor ) );
```

----------------------------------------

TITLE: Minimal fmt::print Example for Code Size Analysis
DESCRIPTION: Provides a simple C++ program using `fmt::print` to demonstrate the compact compiled code size generated by the library, highlighting its efficiency.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/doc/index.rst#_snippet_10

LANGUAGE: C++
CODE:
```
#include <fmt/core.h>

int main() {
  fmt::print("The answer is {}.", 42);
}
```

----------------------------------------

TITLE: Fetch mlx-c External Dependency
DESCRIPTION: Declares and makes available the 'mlx-c' library as an external dependency. It specifies the Git repository URL and the exact Git tag 'v0.2.0' to ensure a consistent version is used for the build.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/CMakeLists.txt#_snippet_1

LANGUAGE: CMake
CODE:
```
FetchContent_Declare(
  mlx-c
  GIT_REPOSITORY "https://github.com/ml-explore/mlx-c.git"
  GIT_TAG "v0.2.0")
FetchContent_MakeAvailable(mlx-c)
```

----------------------------------------

TITLE: Error: Mixing narrow and wide strings in fmt::format
DESCRIPTION: Shows an expected compile-time error when mixing wide format strings with narrow arguments in `fmt::format`.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/test/compile-error-test/CMakeLists.txt#_snippet_1

LANGUAGE: C++
CODE:
```
fmt::format(L"{}", "foo");
```

----------------------------------------

TITLE: MLX Swift API: tri Function
DESCRIPTION: Documents the API path and signature for the `tri` function in MLX Swift, typically used for creating triangular matrices.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/MLX/Documentation.docc/Articles/converting-python.md#_snippet_5

LANGUAGE: APIDOC
CODE:
```
Function: tri
Path: MLXArray/tri(_:m:k:type:stream:)
```

----------------------------------------

TITLE: Configuring Pedantic Compiler Flags for Clang C++
DESCRIPTION: This CMake block defines a set of pedantic and warning flags specifically for the Clang C++ compiler. It includes common warnings like `-Wall`, `-Wextra`, and `-pedantic`, and conditionally adds `-Wzero-as-null-pointer-constant` if supported. It also sets `-Werror` to treat warnings as errors, promoting robust code.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/CMakeLists.txt#_snippet_18

LANGUAGE: CMake
CODE:
```
if(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
  set(PEDANTIC_COMPILE_FLAGS
      -Wall
      -Wextra
      -pedantic
      -Wconversion
      -Wundef
      -Wdeprecated
      -Wweak-vtables
      -Wshadow
      -Wno-gnu-zero-variadic-macro-arguments)
  check_cxx_compiler_flag(-Wzero-as-null-pointer-constant HAS_NULLPTR_WARNING)
  if(HAS_NULLPTR_WARNING)
    set(PEDANTIC_COMPILE_FLAGS ${PEDANTIC_COMPILE_FLAGS}
                               -Wzero-as-null-pointer-constant)
  endif()
  set(WERROR_FLAG -Werror)
endif()
```

----------------------------------------

TITLE: Consistent Infinity Output with fmt::print
DESCRIPTION: Demonstrates the cross-platform consistency of `fmt::print` output, specifically showing that `infinity` is always printed as `inf`, unlike `printf` which can have platform-dependent behavior.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/doc/index.rst#_snippet_12

LANGUAGE: C++
CODE:
```
fmt::print("{}", std::numeric_limits<double>::infinity());
```

----------------------------------------

TITLE: Build fmt with Position Independent Code (PIC) using CMake
DESCRIPTION: CMake command to enable position independent code (PIC) for the fmt library. This is often required if the main consumer of fmt is a shared library, such as a Python extension.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/doc/usage.rst#_snippet_4

LANGUAGE: CMake
CODE:
```
cmake -DCMAKE_POSITION_INDEPENDENT_CODE=TRUE ...
```

----------------------------------------

TITLE: Conditionally Enable and Configure Unit Tests
DESCRIPTION: This CMake block conditionally enables CTest and includes the `tests` subdirectory if the `JSON_BuildTests` option is set to true. This setup integrates the project's unit tests into the build system, allowing them to be run via CTest.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/json/CMakeLists.txt#_snippet_7

LANGUAGE: CMake
CODE:
```
#
# TESTS create and configure the unit test target
#
if(JSON_BuildTests)
  include(CTest)
  enable_testing()
  add_subdirectory(tests)
endif()
```

----------------------------------------

TITLE: fmt Library API Overview
DESCRIPTION: This section provides an overview of the {fmt} library API, detailing the various header files and their respective functionalities for string formatting, ranging from core functions to specialized support for ranges, chrono, standard library types, and system APIs. All functions and types reside in the 'fmt' namespace, and macros use the 'FMT_' prefix.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/doc/api.rst#_snippet_0

LANGUAGE: APIDOC
CODE:
```
fmt library API consists of the following parts:
- fmt/core.h: core API providing main formatting functions for char/UTF-8 with C++20 compile-time checks and minimal dependencies
- fmt/format.h: full format API providing additional formatting functions and locale support
- fmt/ranges.h: formatting of ranges and tuples
- fmt/chrono.h: date and time formatting
- fmt/std.h: formatters for standard library types
- fmt/compile.h: format string compilation
- fmt/color.h: terminal color and text style
- fmt/os.h: system APIs
- fmt/ostream.h: std::ostream support
- fmt/args.h: dynamic argument lists
- fmt/printf.h: printf formatting
- fmt/xchar.h: optional wchar_t support

All functions and types provided by the library reside in namespace fmt and macros have prefix FMT_.
```

----------------------------------------

TITLE: Clone and Configure Format Benchmarks Repository
DESCRIPTION: Instructions to clone the format-benchmark repository and generate Makefiles using CMake. This is a prerequisite step before running any performance tests.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/README.md#_snippet_8

LANGUAGE: Shell
CODE:
```
git clone --recursive https://github.com/fmtlib/format-benchmark.git
cd format-benchmark
cmake .
```

----------------------------------------

TITLE: Build MLXRandom Swift Library
DESCRIPTION: Compiles the MLXRandom Swift library from its source files and defines it as a static library. It links privately against the core MLX library, indicating a dependency on the main MLX functionality.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/CMakeLists.txt#_snippet_4

LANGUAGE: CMake
CODE:
```
file(GLOB MLXRandom-src ${CMAKE_CURRENT_LIST_DIR}/Source/MLXRandom/*.swift)
add_library(MLXRandom STATIC ${MLXRandom-src})
target_link_libraries(MLXRandom PRIVATE MLX)
```

----------------------------------------

TITLE: Generate Single Header File for metal-cpp
DESCRIPTION: Demonstrates how to generate a single header file containing all metal-cpp headers using a Python script. This is an optional step for simplifying header management and can be customized with the -o option.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/metal-cpp/README.md#_snippet_5

LANGUAGE: shell
CODE:
```
./SingleHeader/MakeSingleHeader.py Foundation/Foundation.hpp QuartzCore/QuartzCore.hpp Metal/Metal.hpp MetalFX/MetalFX.hpp
```

----------------------------------------

TITLE: Set CUDA C++ Standard for Compilation in CMake
DESCRIPTION: This snippet explicitly sets the C++ standard for CUDA compilation to C++14. It uses `CMAKE_CUDA_STANDARD` and `CMAKE_CUDA_STANDARD_REQUIRED` to ensure the specified standard is enforced throughout the build process, impacting both host and device code.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/test/cuda-test/CMakeLists.txt#_snippet_0

LANGUAGE: CMake
CODE:
```
set(CMAKE_CUDA_STANDARD 14)
set(CMAKE_CUDA_STANDARD_REQUIRED 14)
```

----------------------------------------

TITLE: Configure and Build the fmt Library with CMake
DESCRIPTION: This CMake script defines the `fmt` library, specifying its headers, source files, and various build configurations. It handles conditional compilation for OS-specific sources, enables C++11 features, sets include directories, manages debug postfixes, and configures shared library exports. It also defines alias targets and properties for versioning and PDB output.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/CMakeLists.txt#_snippet_22

LANGUAGE: CMake
CODE:
```
# Define the fmt library, its includes and the needed defines.
add_headers(
  FMT_HEADERS
  args.h
  chrono.h
  color.h
  compile.h
  core.h
  format.h
  format-inl.h
  os.h
  ostream.h
  printf.h
  ranges.h
  std.h
  xchar.h)
set(FMT_SOURCES src/format.cc)
if(FMT_OS)
  set(FMT_SOURCES ${FMT_SOURCES} src/os.cc)
endif()

add_module_library(
  fmt
  src/fmt.cc
  FALLBACK
  ${FMT_SOURCES}
  ${FMT_HEADERS}
  README.md
  ChangeLog.md
  IF
  FMT_MODULE)
add_library(fmt::fmt ALIAS fmt)
if(FMT_MODULE)
  enable_module(fmt)
endif()

if(FMT_WERROR)
  target_compile_options(fmt PRIVATE ${WERROR_FLAG})
endif()
if(FMT_PEDANTIC)
  target_compile_options(fmt PRIVATE ${PEDANTIC_COMPILE_FLAGS})
endif()

if(cxx_std_11 IN_LIST CMAKE_CXX_COMPILE_FEATURES)
  target_compile_features(fmt PUBLIC cxx_std_11)
else()
  message(WARNING "Feature cxx_std_11 is unknown for the CXX compiler")
endif()

target_include_directories(
  fmt ${FMT_SYSTEM_HEADERS_ATTRIBUTE}
  PUBLIC $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include>
         $<INSTALL_INTERFACE:${FMT_INC_DIR}>)

set(FMT_DEBUG_POSTFIX
    d
    CACHE STRING "Debug library postfix.")

set_target_properties(
  fmt
  PROPERTIES VERSION ${FMT_VERSION}
             SOVERSION ${CPACK_PACKAGE_VERSION_MAJOR}
             PUBLIC_HEADER "${FMT_HEADERS}"
             DEBUG_POSTFIX "${FMT_DEBUG_POSTFIX}"
             # Workaround for Visual Studio 2017:
             # Ensure the .pdb is created with the same name and in the same
             # directory
             # as the .lib. Newer VS versions already do this by default, but
             # there is no
             # harm in setting it for those too. Ignored by other generators.
             COMPILE_PDB_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}"
             COMPILE_PDB_NAME "fmt"
             COMPILE_PDB_NAME_DEBUG "fmt${FMT_DEBUG_POSTFIX}")

# Set FMT_LIB_NAME for pkg-config fmt.pc. We cannot use the OUTPUT_NAME target
# property because it's not set by default.
set(FMT_LIB_NAME fmt)
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
  set(FMT_LIB_NAME ${FMT_LIB_NAME}${FMT_DEBUG_POSTFIX})
endif()

if(BUILD_SHARED_LIBS)
  target_compile_definitions(
    fmt
    PRIVATE FMT_LIB_EXPORT
    INTERFACE FMT_SHARED)
endif()
if(FMT_SAFE_DURATION_CAST)
  target_compile_definitions(fmt PUBLIC FMT_SAFE_DURATION_CAST)
endif()

add_library(fmt-header-only INTERFACE)
add_library(fmt::fmt-header-only ALIAS fmt-header-only)

target_compile_definitions(fmt-header-only INTERFACE FMT_HEADER_ONLY=1)
target_compile_features(fmt-header-only INTERFACE cxx_std_11)

target_include_directories(
  fmt-header-only ${FMT_SYSTEM_HEADERS_ATTRIBUTE}
  INTERFACE $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include>
            $<INSTALL_INTERFACE:${FMT_INC_DIR}>)
```

----------------------------------------

TITLE: Setting CMake Build Type and Runtime Output Directory
DESCRIPTION: This CMake code block first displays the current build type (e.g., Debug, Release). It then conditionally sets the `CMAKE_RUNTIME_OUTPUT_DIRECTORY` to a 'bin' subdirectory within the current binary directory if it hasn't been explicitly defined, ensuring consistent output paths.
SOURCE: https://github.com/ml-explore/mlx-swift/blob/main/Source/Cmlx/fmt/CMakeLists.txt#_snippet_14

LANGUAGE: CMake
CODE:
```
message(STATUS "Build type: ${CMAKE_BUILD_TYPE}")

if(NOT CMAKE_RUNTIME_OUTPUT_DIRECTORY)
  set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/bin)
endif()
```

TITLE: Using Kokoro Model Pipeline - MLX-Audio - Python
DESCRIPTION: Demonstrates how to load the Kokoro model and use its pipeline for text-to-speech generation in Python. The example shows initializing the pipeline, generating audio from text, displaying it (e.g., in a notebook), and saving it to a file.
SOURCE: https://github.com/blaizzy/mlx-audio/blob/main/README.md#_snippet_4

LANGUAGE: python
CODE:
```
from mlx_audio.tts.models.kokoro import KokoroPipeline
from mlx_audio.tts.utils import load_model
from IPython.display import Audio
import soundfile as sf

# Initialize the model
model_id = 'prince-canuma/Kokoro-82M'
model = load_model(model_id)

# Create a pipeline with American English
pipeline = KokoroPipeline(lang_code='a', model=model, repo_id=model_id)

# Generate audio
text = "The MLX King lives. Let him cook!"
for _, _, audio in pipeline(text, voice='af_heart', speed=1, split_pattern=r'\n+'):
    # Display audio in notebook (if applicable)
    display(Audio(data=audio, rate=24000, autoplay=0))

    # Save audio to file
    sf.write('audio.wav', audio[0], 24000)
```

----------------------------------------

TITLE: Generating TTS via Python API - MLX-Audio - Python
DESCRIPTION: Generate text-to-speech audio programmatically using the Python API. This example demonstrates generating a multi-paragraph audiobook chapter with specific settings for model, voice, speed, language code, file format, sample rate, and verbosity.
SOURCE: https://github.com/blaizzy/mlx-audio/blob/main/README.md#_snippet_2

LANGUAGE: python
CODE:
```
from mlx_audio.tts.generate import generate_audio

# Example: Generate an audiobook chapter as mp3 audio
generate_audio(
    text=("In the beginning, the universe was created...\n"
        "...or the simulation was booted up."),
    model_path="prince-canuma/Kokoro-82M",
    voice="af_heart",
    speed=1.2,
    lang_code="a", # Kokoro: (a)f_heart, or comment out for auto
    file_prefix="audiobook_chapter1",
    audio_format="wav",
    sample_rate=24000,
    join_audio=True,
    verbose=True  # Set to False to disable print messages
)

print("Audiobook chapter successfully generated!")
```

----------------------------------------

TITLE: Generate Speech with CSM and Reference Audio (Bash)
DESCRIPTION: Demonstrates how to use the `mlx_audio.tts.generate` script to generate speech using the CSM-1B model. It specifies the model, the text to synthesize, enables playback (`--play`), and provides a reference audio file (`--ref_audio`) for voice cloning.
SOURCE: https://github.com/blaizzy/mlx-audio/blob/main/README.md#_snippet_5

LANGUAGE: bash
CODE:
```
python -m mlx_audio.tts.generate --model mlx-community/csm-1b --text "Hello from Sesame." --play --ref_audio ./conversational_a.wav
```

----------------------------------------

TITLE: Quantize MLX Audio Model (Python)
DESCRIPTION: Shows how to load and quantize an MLX audio model (Kokoro-82M) to 8-bit using `quantize_model`. It then demonstrates how to save the quantized weights and updated configuration to disk in safetensors format. Requires `mlx_audio.tts.utils`, `json`, and `mlx.core`.
SOURCE: https://github.com/blaizzy/mlx-audio/blob/main/README.md#_snippet_6

LANGUAGE: python
CODE:
```
from mlx_audio.tts.utils import quantize_model, load_model
import json
import mlx.core as mx

model = load_model(repo_id='prince-canuma/Kokoro-82M')
config = model.config

# Quantize to 8-bit
group_size = 64
bits = 8
weights, config = quantize_model(model, config, group_size, bits)

# Save quantized model
with open('./8bit/config.json', 'w') as f:
  json.dump(config, f)

mx.save_safetensors("./8bit/kokoro-v1_0.safetensors", weights, metadata={"format": "mlx"})
```
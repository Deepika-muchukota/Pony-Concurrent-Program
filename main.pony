actor Main
  new create(env: Env) =>
    // Check if exactly two arguments are provided
    if env.args.size() != 3 then
      env.out.print("Usage: <program> <N> <K>")
      return
    end

    try
      let arg_n = env.args(1)?
      let arg_k = env.args(2)?

      // Convert arguments to numbers
      let n = arg_n.u32()?
      let k = arg_k.u32()?

      // Validate that N and K are positive numbers
      if (n <= 0) or (k <= 0) then
        env.out.print("Please provide positive numbers for both N and K.")
        return
      end

      // Create a boss actor to handle the calculation
      let boss = Boss(env, n, k)

    else
      // Handle errors for argument access or conversion
      env.out.print("Invalid input! Please provide valid numbers.")
    end

// Boss actor that coordinates the tasks
actor Boss
  let _env: Env
  let _n: U32
  let _k: U32
  var _perfect_square_count: U32 = 0

  new create(env: Env, n: U32, k: U32) =>
    _env = env
    _n = n
    _k = k

    // Start computing sequences
    var start: U32 = 1
    while ((start + _k) - 1) <= _n do
      // Create a worker actor for each sequence to compute sum of squares
      let worker = Worker(this, start, _k)
      start = start + 1
    end

  // Receive the result from a worker and check if it's a perfect square
  be receive_result(start: U32, sum_of_squares: U32) =>
    if is_perfect_square(sum_of_squares) then
      _env.out.print("Sequence starting at " + start.string() + ": Sum of squares = " + sum_of_squares.string() + " (Perfect square!)")
      _perfect_square_count = _perfect_square_count + 1
    end

    // Once all sequences are done, print the result
    if start == ((_n - _k) + 1) then
      _env.out.print("Total number of sequences with perfect square sums: " + _perfect_square_count.string())
    end

  // Method to check if a number is a perfect square
  fun is_perfect_square(x: U32): Bool =>
    let sqrt_x = x.f64().sqrt()
    let sqrt_int = sqrt_x.u32()
    (sqrt_int * sqrt_int) == x

// Worker actor that computes the sum of squares
actor Worker
  let _boss: Boss
  let _start: U32
  let _k: U32

  new create(boss: Boss, start: U32, k: U32) =>
    _boss = boss
    _start = start
    _k = k

    // Compute sum of squares and send result to the boss
    let sum_of_squares = compute_sum_of_squares(_start, _k)
    _boss.receive_result(_start, sum_of_squares)

  // Method to compute the sum of squares of K consecutive numbers starting from 'start'
  fun compute_sum_of_squares(start: U32, k: U32): U32 =>
    var sum: U32 = 0
    var i: U32 = start
    var count: U32 = 0
    while count < k do
      sum = sum + (i * i)
      i = i + 1
      count = count + 1
    end
    sum

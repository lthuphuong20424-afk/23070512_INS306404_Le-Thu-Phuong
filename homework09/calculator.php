<?php
/**
 * INS3064 - Homework 09: Robust Calculator
 * Student Name: DO TO UYEN
 * Student ID: 23070507
 * Date: 2026-11-16
 */

error_reporting(E_ALL);
ini_set('display_errors', '0');
ini_set('log_errors', '1');
date_default_timezone_set('Asia/Ho_Chi_Minh');

session_start();

// 1. Custom exception classes
class DivisionByZeroException extends Exception {}
class InvalidOperatorException extends Exception {}
class InvalidInputException extends Exception {}

// 2. Initialize session history
if (!isset($_SESSION['history'])) {
    $_SESSION['history'] = [];
}

// 3. Escape HTML output
function escapeHtml($value): string {
    return htmlspecialchars(
        (string)$value,
        ENT_QUOTES | ENT_SUBSTITUTE,
        'UTF-8'
    );
}

// 4. Format calculation results
function formatResult(float $number, bool $division = false): string {
    if ($division) {
        return number_format($number, 4, '.', '');
    }

    if ($number == floor($number)) {
        return sprintf('%.0f', $number);
    }

    return rtrim(
        rtrim(sprintf('%.10f', $number), '0'),
        '.'
    );
}

// 5. Log every caught exception
function logCalculatorError(
    Throwable $error,
    string $input
): void {
    $type = (new ReflectionClass($error))->getShortName();

    // Prevent newline injection into log records
    $input = str_replace(["\r", "\n"], ' ', $input);
    $message = str_replace(
        ["\r", "\n"],
        ' ',
        $error->getMessage()
    );

    $ip = $_SERVER['REMOTE_ADDR'] ?? 'unknown';
    $ip = str_replace(["\r", "\n"], '', $ip);

    $record = sprintf(
        '[%s] %s: %s | Input: "%s" | IP: %s%s',
        date('Y-m-d H:i:s'),
        $type,
        $message,
        $input,
        $ip,
        PHP_EOL
    );

    error_log(
        $record,
        3,
        __DIR__ . '/calculator_errors.log'
    );
}

// 6. Calculator logic
function calculate(
    string $rawA,
    string $operator,
    string $rawB
): array {
    $rawA = trim($rawA);
    $rawB = trim($rawB);

    // Validate numeric input
    if (
        $rawA === '' ||
        $rawB === '' ||
        !is_numeric($rawA) ||
        !is_numeric($rawB)
    ) {
        throw new InvalidInputException(
            'Please enter valid numeric values.'
        );
    }

    $a = (float)$rawA;
    $b = (float)$rawB;

    if (!is_finite($a) || !is_finite($b)) {
        throw new OverflowException(
            'Input exceeds numeric limits.'
        );
    }

    // Validate operator
    $allowed = ['+', '-', '*', '/', '%', '**'];

    if (!in_array($operator, $allowed, true)) {
        throw new InvalidOperatorException(
            'Unsupported operator. Please choose a valid one.'
        );
    }

    // Check division and modulo by zero
    if (
        ($operator === '/' || $operator === '%')
        && $b == 0.0
    ) {
        throw new DivisionByZeroException(
            'Cannot divide or modulo by zero.'
        );
    }

    // Execute operation
    switch ($operator) {
        case '+':
            $result = $a + $b;
            break;

        case '-':
            $result = $a - $b;
            break;

        case '*':
            $result = $a * $b;
            break;

        case '/':
            $result = $a / $b;
            break;

        case '%':
            // Use floating-point modulo for numeric inputs
            $result = fmod($a, $b);
            break;

        case '**':
            $result = $a ** $b;
            break;
    }

    // Check overflow and invalid numeric results
    if (!is_finite((float)$result)) {
        throw new OverflowException(
            'Result exceeds numeric limits.'
        );
    }

    $formatted = formatResult(
        (float)$result,
        $operator === '/'
    );

    return [
        'expression' => "$rawA $operator $rawB",
        'result' => $formatted
    ];
}

// 7. Form state
$first = '';
$second = '';
$operator = '+';

$success = '';
$errorMessage = '';
$warning = '';

// 8. Handle POST request
if ($_SERVER['REQUEST_METHOD'] === 'POST') {

    $action = $_POST['action'] ?? 'calculate';

    if ($action === 'clear') {

        $_SESSION['history'] = [];
        $warning = 'Calculation history cleared.';

    } elseif ($action === 'calculate') {

        $first = is_string($_POST['first'] ?? null)
            ? $_POST['first'] : '';

        $second = is_string($_POST['second'] ?? null)
            ? $_POST['second'] : '';

        $operator = is_string($_POST['operator'] ?? null)
            ? $_POST['operator'] : '';

        $rawExpression = "$first $operator $second";

        try {

            $calculation = calculate(
                $first,
                $operator,
                $second
            );

            $success = $calculation['expression']
                . ' = '
                . $calculation['result'];

            $_SESSION['history'][] = [
                'expression' => $calculation['expression'],
                'result' => $calculation['result'],
                'timestamp' => date('Y-m-d H:i:s')
            ];

        } catch (InvalidInputException $e) {

            $errorMessage = $e->getMessage();
            logCalculatorError($e, $rawExpression);

        } catch (InvalidOperatorException $e) {

            $errorMessage = $e->getMessage();
            logCalculatorError($e, $rawExpression);

        } catch (DivisionByZeroException $e) {

            $errorMessage = $e->getMessage();
            logCalculatorError($e, $rawExpression);

        } catch (OverflowException $e) {

            $errorMessage = $e->getMessage();
            logCalculatorError($e, $rawExpression);

        } catch (Throwable $e) {

            $errorMessage =
                'An unexpected error occurred. Please try again.';

            logCalculatorError($e, $rawExpression);
        }

    } else {
        $warning = 'Unknown action.';
    }
}

$history = array_reverse($_SESSION['history']);
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>INS3064 - Robust Calculator</title>

    <style>
        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            padding: 35px 16px;
            font-family: Arial, sans-serif;
            background: #f4f7fe;
            color: #1e293b;
        }

        .container {
            max-width: 850px;
            margin: auto;
        }

        .header {
            text-align: center;
            margin-bottom: 25px;
        }

        .header h1 {
            color: #4f46e5;
            margin-bottom: 8px;
        }

        .header p {
            color: #64748b;
        }

        .card {
            background: white;
            border-radius: 16px;
            padding: 28px;
            margin-bottom: 24px;
            box-shadow: 0 4px 20px rgba(0,0,0,.04);
        }

        h2 {
            margin-top: 0;
            font-size: 20px;
        }

        .form-grid {
            display: grid;
            grid-template-columns: 1fr 120px 1fr;
            gap: 15px;
        }

        label {
            display: block;
            margin-bottom: 8px;
            font-size: 14px;
            font-weight: bold;
        }

        input, select {
            width: 100%;
            padding: 12px;
            border: 1px solid #cbd5e1;
            border-radius: 8px;
            font-size: 16px;
            background: white;
        }

        input:focus, select:focus {
            outline: none;
            border-color: #6366f1;
        }

        .actions {
            display: flex;
            gap: 12px;
            margin-top: 22px;
        }

        button {
            padding: 12px 20px;
            border: none;
            border-radius: 8px;
            font-weight: bold;
            cursor: pointer;
        }

        .btn-primary {
            background: #4f46e5;
            color: white;
        }

        .btn-primary:hover {
            background: #4338ca;
        }

        .btn-clear {
            background: #e2e8f0;
            color: #334155;
        }

        .message {
            padding: 16px;
            border-radius: 10px;
            margin-top: 20px;
            overflow-wrap: anywhere;
        }

        .success {
            background: #dcfce7;
            border: 1px solid #86efac;
            color: #166534;
        }

        .error {
            background: #fee2e2;
            border: 1px solid #fca5a5;
            color: #991b1b;
        }

        .warning {
            background: #fef9c3;
            border: 1px solid #fde047;
            color: #854d0e;
        }

        .table-wrapper {
            overflow-x: auto;
        }

        table {
            width: 100%;
            border-collapse: collapse;
        }

        th, td {
            padding: 13px;
            border-bottom: 1px solid #e2e8f0;
            text-align: left;
        }

        th {
            background: #f8fafc;
            color: #475569;
        }

        .empty {
            text-align: center;
            padding: 24px;
            color: #94a3b8;
        }

        .footer {
            text-align: center;
            color: #94a3b8;
            font-size: 13px;
        }

        @media (max-width: 600px) {
            .form-grid {
                grid-template-columns: 1fr;
            }

            .actions {
                flex-direction: column;
            }

            button {
                width: 100%;
            }

            .card {
                padding: 20px;
            }
        }
    </style>
</head>

<body>

<div class="container">

    <div class="header">
        <h1>Robust Calculator</h1>
        <p>INS3064 - Homework 09</p>
        <p>Error Handling & Session History</p>
    </div>

    <div class="card">

        <h2>Calculator</h2>

        <form method="POST" action="calculator.php">

            <input type="hidden"
                   name="action"
                   value="calculate">

            <div class="form-grid">

                <div>
                    <label>First Number</label>
                    <input
                        type="text"
                        name="first"
                        placeholder="Enter first number"
                        value="<?= escapeHtml($first) ?>">
                </div>

                <div>
                    <label>Operator</label>
                    <select name="operator">

                        <?php
                        $operators = [
                            '+' => '+',
                            '-' => '-',
                            '*' => '*',
                            '/' => '/',
                            '%' => '%',
                            '**' => '**'
                        ];

                        foreach ($operators as $value => $label):
                        ?>
                            <option
                                value="<?= escapeHtml($value) ?>"
                                <?= $operator === $value
                                    ? 'selected' : '' ?>>
                                <?= escapeHtml($label) ?>
                            </option>
                        <?php endforeach; ?>

                        <?php if (
                            !array_key_exists($operator, $operators)
                        ): ?>
                            <option
                                value="<?= escapeHtml($operator) ?>"
                                selected>
                                Invalid: <?= escapeHtml($operator) ?>
                            </option>
                        <?php endif; ?>

                    </select>
                </div>

                <div>
                    <label>Second Number</label>
                    <input
                        type="text"
                        name="second"
                        placeholder="Enter second number"
                        value="<?= escapeHtml($second) ?>">
                </div>

            </div>

            <div class="actions">
                <button
                    type="submit"
                    class="btn-primary">
                    Calculate
                </button>
            </div>

        </form>

        <form method="POST"
              action="calculator.php"
              style="margin-top:12px;">

            <input type="hidden"
                   name="action"
                   value="clear">

            <button
                type="submit"
                class="btn-clear">
                Clear History
            </button>

        </form>

        <?php if ($success !== ''): ?>
            <div class="message success">
                <strong>Success!</strong>
                <?= escapeHtml($success) ?>
            </div>
        <?php endif; ?>

        <?php if ($errorMessage !== ''): ?>
            <div class="message error">
                <strong>Error:</strong>
                <?= escapeHtml($errorMessage) ?>
            </div>
        <?php endif; ?>

        <?php if ($warning !== ''): ?>
            <div class="message warning">
                <?= escapeHtml($warning) ?>
            </div>
        <?php endif; ?>

    </div>

    <div class="card">

        <h2>Calculation History</h2>

        <?php if (empty($history)): ?>

            <div class="empty">
                No calculations yet.
            </div>

        <?php else: ?>

            <div class="table-wrapper">
                <table>
                    <thead>
                        <tr>
                            <th>#</th>
                            <th>Expression</th>
                            <th>Result</th>
                            <th>Timestamp</th>
                        </tr>
                    </thead>

                    <tbody>
                    <?php foreach ($history as $index => $item): ?>
                        <tr>
                            <td><?= $index + 1 ?></td>
                            <td>
                                <?= escapeHtml($item['expression']) ?>
                            </td>
                            <td>
                                <?= escapeHtml($item['result']) ?>
                            </td>
                            <td>
                                <?= escapeHtml($item['timestamp']) ?>
                            </td>
                        </tr>
                    <?php endforeach; ?>
                    </tbody>
                </table>
            </div>

        <?php endif; ?>

    </div>

    <div class="footer">
        INS3064 - Web Development | Homework 09
    </div>

</div>

</body>
</html>

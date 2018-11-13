<?php
namespace App\Http\Controllers;

/*
|--------------------------------------------------------------------------
| Application Routes
|--------------------------------------------------------------------------
|
| Here is where you can register all of the routes for an application.
| It is a breeze. Simply tell Lumen the URIs it should respond to
| and give it the Closure to call when that URI is requested.
|
*/

$router->get('/', function () use ($router) {
    return response()->json([
        'container_id' => gethostname()
    ]);
});

// User
$router->get('/expense', ExpenseController::class . '@index');
$router->post('/expense', ExpenseController::class . '@store');

$router->get('/expense/{uuid}', ExpenseController::class . '@show');
$router->put('/expense/{uuid}', ExpenseController::class . '@update');
$router->delete('/expense/{uuid}', ExpenseController::class . '@destroy');

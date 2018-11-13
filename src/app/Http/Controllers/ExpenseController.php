<?php

namespace App\Http\Controllers;

use App\Entities\Expense;
use Illuminate\Http\Request;

class ExpenseController extends Controller
{
    /**
     * @param Expense $expense
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function index(Expense $expense)
    {
        return response()->json($expense->all());
    }

    /**
     * @param Expense $expense
     * @param string $uuid
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function show(Expense $expense, string $uuid)
    {

        return response()->json($expense->find($uuid));
    }

    /**
     * @param Request $request
     * @param Expense $expense
     *
     * @throws \Illuminate\Validation\ValidationException
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function store(Request $request, Expense $expense)
    {

        $this->validate($request, [
            'id' => [
                'regex:/^[0-9a-fA-F]{8}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{12}$/',
                'unique:expense,id',
            ],
            'name' => 'required|max:255',
            'value' => 'required|numeric|min:0.01|max:9007199254740992',
        ]);

        return response()->json(
            $expense->create(
                $request->all()
            )
        );
    }
    /**
     * @param Request $request
     * @param Expense $expense
     * @param string $id
     *
     * @throws \Illuminate\Validation\ValidationException
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function update(Request $request, Expense $expense, string $id)
    {
        $this->validate($request, [
            'name' => 'required|max:255',
            'value' => 'numeric|min:0.01|max:9007199254740992',
        ]);

        $expenseEntity = $expense->findOrFail($id);

        $expenseEntity->update($request->all());

        return response()->json($expenseEntity);
    }


    /**
     * @param Expense $expense
     * @param $uuid
     *
     * @throws \Illuminate\Database\Eloquent\ModelNotFoundException
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function destroy(Expense $expense, $uuid)
    {
        $expenseEntity = $expense->findOrFail($uuid);

        $expenseEntity->delete();

        return response()->json($expenseEntity);
    }

}

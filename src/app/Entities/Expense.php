<?php

namespace App\Entities;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

final class Expense extends Model
{
    use SoftDeletes, Traits\Uuid;

    /**
     * The table associated with the model.
     *
     * @var string
     */
    protected $table = 'expense';

    /**
     * The attributes that are mass assignable.
     *
     * @var array
     */
    protected $fillable = [
        'id',
        'name',
        'value',
    ];

    /**
     * The parameter disables the automatic increment.
     *
     * @var string
     */
    public $incrementing = false;


    /**
     * The attributes that should be mutated to dates.
     *
     * @var array
     */
    protected $dates = ['deleted_at'];
}

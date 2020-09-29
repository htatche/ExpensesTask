import React, { useEffect, useState } from "react";
import { useParams, useHistory } from "react-router-dom";
import LoadingIndicator from "./LoadingIndicator";
import ErrorMessage from "./ErrorMessage";
import request from "../request";
import styles from "./ExpenseEdit.module.css";
import Button from "./Button";
import { useNotifications } from "./Notifications";

function ExpenseForm({ expense, onSave, disabled, onDelete }) {
  const [changes, setChanges] = useState({});
  const [accounts, setAccounts] = useState([]);
  const [loading, setLoading] = useState(true);
  const { notifyError } = useNotifications();

  function changeField(field, value) {
    setChanges({
      ...changes,
      [field]: value,
    });
  }

  const formData = {
    ...expense,
    ...changes,
  };

  function handleSubmit(event) {
    event.preventDefault();
    onSave(changes);
  }

  useEffect(() => {
    let unmounted = false;
    async function getAccounts() {
      try {
        const response = await fetch("/accounts");
        if (response.ok) {
          const body = await response.json();
          if (!unmounted) {
            setAccounts(
              body.map(({ id, name, number }) => ({
                id: id,
                name: name,
                number: number,
              }))
            );

            setLoading(false);

	    changeField("account_id", formData.account_id || body[0].id);
          }
        } else {
          notifyError("Failed to load accounts. Please try again");
        }
      } catch (error) {
        notifyError(
          "Failed to load accounts. Please check your internet connection"
        );
      }
    }

    getAccounts();

    return () => {
      unmounted = true;
    };
  }, []);

  return (
    <form autoComplete={"off"} onSubmit={handleSubmit} className={styles.form}>
      <fieldset disabled={disabled ? "disabled" : undefined}>
        <div className={styles.formRow}>
          <label htmlFor="account">Account</label>
          <select
            name="accounts"
            id={"account_id"}
            disabled={loading}
            value={formData.account_id}
            onChange={(e) => changeField("account_id", e.target.value)}
          >
            {accounts.map(({ id, name, number }) => (
              <option key={number} value={id}>
                {name}
              </option>
            ))}
          </select>
        </div>

        <div className={styles.formRow}>
          <label htmlFor="amount">Amount</label>
          <input
            required
            min={"0"}
            id={"amount"}
            type={"number"}
            value={formData.amount}
            onChange={(event) => changeField("amount", event.target.value)}
          />
        </div>

        <div className={styles.formRow}>
          <label htmlFor="date">Date</label>
          <input
            required
            id={"date"}
            type={"date"}
            value={formData.date}
            onChange={(event) => changeField("date", event.target.value)}
          />
        </div>

        <div className={styles.formRow}>
          <label htmlFor="description">Description</label>
          <input
            required
            id={"description"}
            type={"text"}
            value={formData.description}
            onChange={(event) => changeField("description", event.target.value)}
          />
        </div>
      </fieldset>

      <div className={styles.formFooter}>
        {expense.id && (
          <Button action={onDelete} kind={"danger"} disabled={disabled}>
            Delete
          </Button>
        )}
        <Button
          type={"submit"}
          disabled={Object.keys(changes).length === 0 || disabled}
        >
          Save
        </Button>
      </div>
    </form>
  );
}

const defaultExpenseData = {
  amount: 0,
  date: new Date().toISOString().substr(0, 10),
  description: "",
  account_id: 0,
};

function ExpenseEdit() {
  const { id } = useParams();
  const history = useHistory();
  const [expense, setExpense] = useState(id ? null : defaultExpenseData);
  const [loadingStatus, setLoadingStatus] = useState(id ? "loading" : "loaded");
  const [isSaving, setSaving] = useState(false);
  const [isDeleting, setDeleting] = useState(false);
  const { notifyError } = useNotifications();

  useEffect(
    function () {
      async function loadExpense() {
        try {
          const response = await request(`/expenses/${id}`, {
            method: "GET",
          });
          if (response.ok) {
            setExpense(response.body);
            setLoadingStatus("loaded");
          } else {
            setLoadingStatus("error");
          }
        } catch (error) {
          setLoadingStatus("error");
        }
      }

      if (id) {
        loadExpense();
      }
    },
    [id]
  );

  async function handleSave(changes) {
    try {
      setSaving(true);

      const url = expense.id ? `/expenses/${expense.id}` : "/expenses";
      const method = expense.id ? "PATCH" : "POST";
      const body = expense.id ? changes : { ...defaultExpenseData, ...changes };
      const response = await request(url, {
        method,
        body,
      });
      if (response.ok) {
        setExpense(response.body);
	setSaving(false);

        history.push("/expenses");
      } else {
	notifyError(
	  Object.entries(response.body).map(function(el) {
            return `${el[0]}: ${el[1]}`
          })
        )
	setSaving(false);
      }
    } catch (error) {
      setSaving(false);
      notifyError(
        "Failed to save expense. Please check your internet connection"
      );
    }
  }

  async function handleDelete() {
    setDeleting(true);

    try {
      const response = await request(`/expenses/${expense.id}`, {
        method: "DELETE",
      });
      if (response.ok) {
        setDeleting(false) 
        history.push("/expenses");
      } else {
        setDeleting(false) 
        notifyError("Failed to delete expense. Please try again");
      }
    } catch (error) {
      setDeleting(false) 
      notifyError(
        "Failed to delete expense. Please check your internet connection"
      );
    } 
  }

  let content;
  if (loadingStatus === "loading") {
    content = <LoadingIndicator />;
  } else if (loadingStatus === "loaded") {
    content = (
      <ExpenseForm
        key={expense.updated_at}
        expense={expense}
        onSave={handleSave}
        disabled={isSaving || isDeleting}
        onDelete={handleDelete}
      />
    );
  } else if (loadingStatus === "error") {
    content = <ErrorMessage />;
  } else {
    throw new Error(`Unexpected loadingStatus: ${loadingStatus}`);
  }

  return <div>{content}</div>;
}

export default ExpenseEdit;

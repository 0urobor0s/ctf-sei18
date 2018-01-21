<?php include("config.inc"); ?>

<div class="col">
<h2>Search Products</h2>

<?php
$search = "";
if (isset($_POST["search"]))
$search = $_POST["search"];
?>

<form method="post">
Search for a product : <input type="text" name="search" value="<?php echo htmlentities($search); ?>" />
<input type="submit" name="submit" value="Search" />
</form><br /><br /><br />


<?php
// Define vars.
$conn = @mysql_connect(DB_SERVER, DB_USER, DB_PWD);
$query = "SELECT User FROM mysql.user WHERE User LIKE '$search'";

// Connection is OK.
if ($conn)
{
	// Table head.
	echo '<table class="listTable" cellspacing="0" cellpadding="0">';
	echo '<tr>';
	echo '<td class="listHead">User</td>';
	echo '</tr>';

	// Display message when search is empty.
	if ($search == "")
	{
		echo '<tr>';
		echo '<td colspan="2" class="listRow" style="text-align:center;"><i>Enter something in the search box</i></td>';
		echo '</tr>';
		$query = "<i>No query was executed because search is empty.</i>";
	}
	// Execute query.
	else
	{
		@mysql_select_db(DB_NAME);
		$result = @mysql_query($query);

		if (@mysql_num_rows($result)==0)
		{
			echo '<tr>';
			echo '<td colspan="2" class="listRow" style="text-align:center;"><i>no results</i></td>';
			echo '</tr>';
		}
		else
		{
			// Listing data in table.
			while ($row = @mysql_fetch_array($result))
			{
				echo '<tr>';
				echo '<td class="listRow">'.$row['User'].'</td>';
				echo '</tr>';
			}
		}
	}
	echo '</table>';
}


?>
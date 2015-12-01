#
# Create a DAL class for a given Table Name
#


#
# Parmaters - change these as necessary
#
$DbServer   = "<DBServer>"
$DbName     = "<DbName>"
$TableName  = "<TableName>"
$OutputFile = "$($TableName)DAL.cs"


$DbConnectionString = "Data Source=$($DbServer);Initial Catalog=$($DbName);Integrated Security=True"

$SqlConnection = New-Object System.Data.SqlClient.SqlConnection
$SqlConnection.ConnectionString = $DbConnectionString


function GetSqlResults($paramSqlCmd)
{
    $SqlCmd = New-Object System.Data.SqlClient.SqlCommand
    $SqlCmd.CommandText = $paramSqlCmd
    $SqlCmd.Connection = $SqlConnection

    $SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
    $SqlAdapter.SelectCommand = $SqlCmd
    $DataSet = New-Object System.Data.DataSet
    $RowCount = $SqlAdapter.Fill($DataSet)

    $SqlConnection.Close()

    return $DataSet.Tables[0]
}

function Generate-CreateMethod
{
    #
    # Generate the <tablename>_Create method
    #

    $SqlCmdText = "
    declare @id int = (select id from sysobjects where xtype='U' and name = '$($TableName)')

    select 'cmd.Parameters.Add(Sql_Utils.CreateParam' + 
	    CASE xtype
			     WHEN 56 THEN 'Int'
			     WHEN 167 THEN 'String'
			     WHEN 231 THEN 'String'
			     WHEN 61 THEN 'DateTime'
			     WHEN 52 THEN 'Int16'
			     WHEN 104 THEN 'Bool'
			     ELSE 'Other'
		      END + '(""' + '@' + name  + '""' + ', item.' + name + '));'
    from syscolumns where id=@id
    "

    "
	public int $($TableName)_Create($($TableName) item)
	{
		string connString = connString = Sql_Utils.GetConnectionString();
		int returnVal = 0;
		using (SqlConnection connection = new SqlConnection(connString))
		{
			connection.Open();

			using (SqlCommand cmd = new SqlCommand(""$($TableName)_Create"", connection))
			{
				cmd.CommandType = CommandType.StoredProcedure;
    "

    GetSqlResults -paramSqlCmd $SqlCmdText |
        ForEach-Object {
            $OutputLine = $_
            if ($OutputLine.Column1 -notmatch "$($TableName)Id")
            {
                # Id columns not used for Creates...
                "				$($OutputLine.Column1)"
            }
        }

    "
				returnVal = Convert.ToInt32(cmd.ExecuteScalar());
			}
			return returnVal;
		}
	}
    "
}



function Generate-ReadMethod
{
    #
    # Generate the <tablename>_Get method
    #

    $SqlCmdText = "
    declare @id int = (select id from sysobjects where xtype='U' and name = '$($TableName)')

    select 'item.' + name + ' = Sql_Utils.Get' + 
	    CASE xtype
			     WHEN 56 THEN 'Int'
			     WHEN 167 THEN 'String'
			     WHEN 231 THEN 'String'
			     WHEN 61 THEN 'DateTime'
			     WHEN 52 THEN 'Int16'
			     WHEN 104 THEN 'Bool'
			     ELSE 'Other'
		      END + '(dr, ""' + name  + '"");'
    from syscolumns where id=@id

    "

    "
	public $($TableName) $($TableName)_Get(int $($TableName)Id)
	{
		$($TableName) item = new $($TableName)();

		string connString = connString = Sql_Utils.GetConnectionString();

		using (SqlConnection connection = new SqlConnection(connString))
		{
			connection.Open();

			using (SqlCommand cmd = new SqlCommand(""$($TableName)_Get"", connection))
			{
				cmd.CommandType = CommandType.StoredProcedure;
				cmd.Parameters.Add(Sql_Utils.CreateParamInt(""@$($TableName)Id"", $($TableName)Id));

				using (SqlDataReader dr = cmd.ExecuteReader())
				{
					dr.Read();

    "

    GetSqlResults -paramSqlCmd $SqlCmdText |
        ForEach-Object {
            $OutputLine = $_
            "					$($OutputLine.Column1)"

        }

    "
			    }
		    }
		    return item;
	    }
    }

    "
}

function Generate-UpdateMethod
{
    #
    # Generate the <tablename>_Update method
    #

    $SqlCmdText = "
    declare @id int = (select id from sysobjects where xtype='U' and name = '$($TableName)')

    select 'cmd.Parameters.Add(Sql_Utils.CreateParam' + 
	    CASE xtype
			     WHEN 56 THEN 'Int'
			     WHEN 167 THEN 'String'
			     WHEN 231 THEN 'String'
			     WHEN 61 THEN 'DateTime'
			     WHEN 52 THEN 'Int16'
			     WHEN 104 THEN 'Bool'
			     ELSE 'Other'
		      END + '(""' + '@' + name  + '""' + ', item.' + name + '));'
    from syscolumns where id=@id
    "

    "
	public int $($TableName)_Update($($TableName) item)
	{
		string connString = connString = Sql_Utils.GetConnectionString();
		int returnVal = 0;
		using (SqlConnection connection = new SqlConnection(connString))
		{
			connection.Open();

			using (SqlCommand cmd = new SqlCommand(""$($TableName)_Create"", connection))
			{
				cmd.CommandType = CommandType.StoredProcedure;
    "

    GetSqlResults -paramSqlCmd $SqlCmdText |
        ForEach-Object {
            $OutputLine = $_
            "				$($OutputLine.Column1)"

        }

    "
				returnVal = Convert.ToInt32(cmd.ExecuteScalar());
			}
			return returnVal;
		}
	}
    "
}


function Generate-DeleteMethod
{
    #
    # Generate the <tablename>_Delete method
    #
"
	public int $($TableName)_Delete(int $($TableName)Id)
	{
		string connString = connString = Sql_Utils.GetConnectionString();
		int returnVal = 0;
		using (SqlConnection connection = new SqlConnection(connString))
		{
			connection.Open();

			using (SqlCommand cmd = new SqlCommand(""$($TableName)_Delete"", connection))
			{
				cmd.CommandType = CommandType.StoredProcedure;
				cmd.Parameters.Add(Sql_Utils.CreateParamInt(""@$($TableName)Id"", $($TableName)Id));

				returnVal = Convert.ToInt32(cmd.ExecuteScalar());
			}
			return returnVal;
		}
	}
"
}

#
# The Ouput class
#

cls

"
public class $($TableName)DAL
{
" | Out-File -FilePath $OutputFile
Generate-CreateMethod | Out-File -FilePath $OutputFile -Append
Generate-ReadMethod | Out-File -FilePath $OutputFile -Append
Generate-UpdateMethod | Out-File -FilePath $OutputFile -Append
Generate-DeleteMethod | Out-File -FilePath $OutputFile -Append
"
}
" | Out-File -FilePath $OutputFile -Append

#"
#public class $($TableName)DAL
#{
#"
#Generate-CreateMethod
#Generate-ReadMethod
#Generate-UpdateMethod
#Generate-DeleteMethod
#"
#}
#"


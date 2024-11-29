# project beginning 
# create database , list databases , connect to database,drop database                                                                                                                                                         
function createdb(){
    read -p "Please enter your new database's name : " dbname
if [[ -z $dbname ]]; then # -z checks if the variable is empty string and returns true if it is 
echo "Error : You can't leave the database's name empty"
fi 

case $dbname in 
[0-9]*)
echo "Database name can't start with a number"

;;
*[[:space:]]*)
echo "Database name can't contain a space"

;;
*[^a-zA-Z0-9_-]*)
echo "Database name can't contain special characters"

;;
*)
if [[ -e $dbname ]]; then 
 echo "Database already exists"
 else
mkdir $dbname
echo "Database created successfully"  
fi 
;;
esac 
}

function listdb() {
    # Check if there are any directories in the current location
    if ls -d */ > /dev/null 2>&1; then
        echo "Databases List:"
        ls -d */  # List directories only
    else
        echo "No databases to list."
    fi
}


function createtable(){
	
	read -p "enter table name: " table_name
#table name validations
    if [[ "$table_name" == *" "* || "$table_name" == "" ]]; then
        echo "Error: table name contains spaces. please enter another name."
    elif [[ "$table_name" =~ ^[0-9] ]]; then
        echo "Error: Table name cannot start with a number please enter another name."
    elif [[ "$table_name" =~ ^[^a-zA-Z] ]]; then
        echo "Error: table name cannot start with symbols please enter another name."
    elif [ -e $table_name ] || [ -e ".meta$table_name" ]; then
        echo "Table already exists."
	else 
		touch $table_name
		read -p "enter number of fields: " fields_no	
        if [[ "$fields_no" =~ ^[^0-9]{2,3}$ ]]
        then
            echo "invalid number of fields"
            rm $table_name
            exit
        fi    



#columns structure
	if [ $fields_no -gt 0 ]
	then
		#pk=0

    ((order=1))
#loop on fields to add it one byy one
    for ((i=0; i<$fields_no; i++))
    do
        line=""
        
        if [ "$order" -eq 1 ]
        then
            read -p "Please enter 1st column name an please ensure that it is the pk and its datatype is int: " col_name
            #pk=1
        elif [ "$order" -eq 2 ]
        then
            read -p "Please enter 2nd column name: " col_name
        elif [ "$order" -eq 3 ]
        then
            read -p "Please enter 3rd column name: " col_name
        else
            read -p "Please enter "$order"th column name: " col_name
        fi

#column name validation

        while true
        do
            if [[ "$col_name" == *" "* || "$col_name" == "" ]]; then
                echo "Error: Column name cannot contain spaces. Please enter a valid column name."
                read -p "Please enter "$order"th column name: " col_name
            elif [[ "$col_name" =~ ^[0-9] ]]; then
                echo "Error: Column name cannot start with a number. Please enter a valid column name."
                read -p "Please enter "$order"th column name: " col_name
            elif [[ "$col_name" =~ ^[^a-zA-Z] ]]; then
                echo "Error: Column name cannot start with a symbol. Please enter a valid column name."
                read -p "Please enter "$order"th column name: " col_name
            else
                line+=:$col_name
                break
            fi
        done


		select datatype in int float char string 
        do 
            case $datatype in 
            "int")
                line+=:$datatype
                break
                ;;
            "float")
                line+=:$datatype
                break
                ;;
            "char")
                line+=:$datatype
                break
                ;;
            "string")
                line+=:$datatype
                break
                ;;
             *)
                echo "Invalid option"
        ;;
            esac
        done


		if [ "$order" -eq 1 ]
		then
                #checking if its an int
                if [ $datatype != int ]
                then
                    echo "PK column must be of integer data type."
                    rm $table_name
                    exit  
                else 
                    	line+=:PK
                fi
        fi

        ((order++))



        # else 
        #     read -p "Do you want to add NOT NULL constraint to this column? (y/n): " add_constraints
        #     if [[ "yes" =~ $add_constraints ]]
        #     then
        #         line+=:NOTNULL
        #     fi 
        #     read -p "Do you want to add UNIQUE constraint to this column? (y/n): " add_unique
        #     if [[ "yes" =~ $add_unique ]]
        #     then
        #         line+=:UNIQUE
        #     fi
        # fi

	
		echo ${line:1} >> ".meta$table_name"
	done
	fi
	fi
	

}


function insertdata(){

        
# Default to current directory if $dbname is not set in connect
    # dbname=${dbname:-(pwd)}    
    #field_no=$(awk -v col_name="$col_name" '{if ($1 == col_name) {print NR}} ' temp_file)

    
    

tables=($(ls "$dbname" | grep -v "^\.meta" | grep -v "^\."))
if [ ${#tables[@]} -eq 0 ]; then
    echo "There are no tables in the database to insert data into."
   return 1
fi

# Display the list of tables
echo "Available tables in database $dbname:"
select tablename in "${tables[@]}"; do
    if [[ -n $tablename ]]; then
        echo "You selected table $tablename."
        break
    else
        echo "Invalid selection. Please try again."
    fi
done




total_cols=$(awk -F : 'END{print NR}' $dbname/.meta$tablename)
 record=""
for ((i=1; i<=total_cols; i++)) do 
col_name=$(awk -F : 'NR=='$i' {print $1}' $dbname/.meta$tablename) 
col_datatype=$(awk -F : 'NR=='$i' {print $2}' $dbname/.meta$tablename) 
col_constraints=$(awk -F : 'NR=='$i' {print $3}' $dbname/.meta$tablename) 



#$dbname/.meta$tablename

while true; do 
read -p "Please enter data into $col_name (This column's type is $col_datatype , and it's constraints : $col_constraints): " coldata

if [[ $col_constraints == *"PK"* ]]; then


if [[ -z $coldata ]]; then 
echo "Data can't be empty for primary key"
continue
fi 

if grep -q "^$coldata" $dbname/$tablename; then 
echo "Enter a unique value for the primary key"
continue 
fi 
fi 

    if [[ $coldata == " "* || $coldata == "" || $coldata == *" "   ]]; then 
    #if [[ $coldata =~ *[[:space:]]* ]]; then 
    echo " Entered data can't contain a space !" # allows spaces in the beginning and end 

    
    elif [[ $col_datatype == "int"  && ! $coldata =~ ^[0-9]+$ ]]; then
    echo "Please enter valid data , Only numbers are allowed "
   
    elif [[ $col_datatype == "float"  && ! $coldata =~ ^[0-9]+$ ]]; then
    echo "Invalid data is entered , Only numbers are allowed"
    
     elif [[ $col_datatype == "string"  && ! $coldata =~ ^[a-zA-Z]+$ ]]; then
    echo "Invalid data is entered , Only String is allowed"

      elif [[ $col_datatype == "char"  && ! $coldata =~ ^[a-zA-Z]$ ]]; then
    echo "Invalid data is entered , Only an alphabetic letter is allowed"
  else
       break
    fi 
done 

   
   
    if [ -z "$record" ]; then
        record="$coldata"  # First field, no colon
    else
        record+=:$coldata  
    fi
done

# Append the new record to the m/employees file (new line for the new record)
echo  $record >> $dbname/$tablename

echo "New record added: $record to the table $tablename"
}



function updatedb() {
    echo "Available tables in the database:"
    # List all tables (assume tables are files without the .meta extension)
    tables=$(ls -p | grep -v '/$' | grep -v '.meta')
    if [[ -z $tables ]]; then
        echo "No tables available in the database."
        return
    fi

    select table_name in $tables; do
        if [[ -n $table_name ]]; then
            echo "You selected table: $table_name"
            break
        else
            echo "Invalid choice. Please select a valid table."
        fi
    done

    if [[ -z $table_name ]]; then
        echo "No table selected. Exiting update operation."
        return
    fi

    if [[ ! -s $table_name ]]; then
        echo "The table is empty. You can't update data in an empty table."
        return
    fi

    read -p "Enter the primary key of the record you want to update: " ptoken

    # Get the index of the primary key column from the metadata
    pk_col_index=$(awk -F: '/PK/ {print NR}' ".meta$table_name")



    # Search for the primary key in the actual data table, at the primary key column index
    # Ensure we are looking at the correct column in the table data
    if ! awk -F: -v pk="$ptoken" -v idx="$pk_col_index" '{if ($idx == pk) print $0}' "$table_name" | grep -q "$ptoken"; then
        echo "The entered primary key does not exist in the '$table_name' table."
        return
    fi

    echo "Available columns in the table:"
    total_cols=$(awk -F: 'END{print NR}' ".meta$table_name")
    for ((j = 2; j <= total_cols; j++)); do
        col_name=$(awk -F: 'NR=='$j' {print $1}' ".meta$table_name")
        echo "$j. $col_name"
    done

    read -p "Choose the number of the column you want to update: " col_num
    if ! [[ $col_num =~ ^[0-9]+$ ]] || [ $col_num -lt 2 ] || [ $col_num -gt $total_cols ]; then
        echo "Please enter a valid column number."
        return
    fi

    chosen_col=$(awk -F: 'NR=='$col_num' {print $1}' ".meta$table_name")
    col_datatype=$(awk -F: 'NR=='$col_num' {print $2}' ".meta$table_name")
    col_constraints=$(awk -F : 'NR=='$col_num' {print $3}' ".meta$table_name")

    # Get the record using primary key
    record=$(awk -F: -v pk="$ptoken" -v idx="$pk_col_index" '{if ($idx == pk) print $0}' "$table_name")
    # Get the value of the chosen column
    current_value=$(echo "$record" | cut -d: -f"$col_num")
    echo "Current value of column '$chosen_col': $current_value"

    read -p "Enter the new value for column '$chosen_col': " new_value

    # Validate the new value based on column datatype
    case $col_datatype in
            int)
                if ! [[ $new_value =~ ^-?[0-9]+$ ]]; then
                    echo "Invalid input. The value for '$chosen_col' must be an integer."
                    return
                fi
                ;;

            float)
                if ! [[ $new_value =~ ^-?[0-9]+\.[0-9]+$ ]]; then
                    echo "Invalid input. The value for '$chosen_col' must be a float."
                    return
                fi
                ;;

            char)
                if ! [[ $new_value =~ ^[a-zA-Z]$ ]]; then
                    echo "Invalid input. The value for '$chosen_col' must be a single alphabetic character."
                    return
                fi
                ;;

            string)
                if [[ $new_value =~ [^a-zA-Z0-9[:space:]] ]]; then
                    echo "Invalid input. The value for '$chosen_col' must be a valid string."
                    return
                fi
                ;;

            *)
                echo "Unknown data type: $col_datatype. Cannot validate input."
                return
                ;;

    esac



    # Update the record
    new_record=$(echo "$record" | awk -F: -v idx="$col_num" -v val="$new_value" 'BEGIN{OFS=":"} {$idx=val; print}')
    sed -i "/^$ptoken:/s/.*/$new_record/" "$table_name"

    echo "Column '$chosen_col' updated successfully. New value: $new_value"
}

function deletetb() {
    echo "Available tables in the database:"
    tables=$(ls -p | grep -v '/$' | grep -v '.meta')
    if [[ -z $tables ]]; then
        echo "No tables available in the database."
        return
    fi

    select table_name in $tables; do
        if [[ -n $table_name ]]; then
            echo "You selected table: $table_name"
            break
        else
            echo "Invalid choice. Please select a valid table."
        fi
    done

    if [[ ! -s $table_name ]]; then
        echo "The table is empty. No data to delete."
        return
    fi

    read -p "Choose an option to delete: 1) Delete entire record by primary key, 2) Delete a specific column value in a record: " option
    case $option in
        1)
            # Delete the entire record
            read -p "Enter the primary key of the record you want to delete: " ptoken

            # Get the index of the primary key column from the metadata
            pk_col_index=$(awk -F: '/PK/ {print NR}' ".meta$table_name")

            # Ensure the primary key exists
            if ! awk -F: -v pk="$ptoken" -v idx="$pk_col_index" '{if ($idx == pk) print $0}' "$table_name" | grep -q "$ptoken"; then
                echo "The entered primary key does not exist in the '$table_name' table."
                return
            fi

            # Delete the record
            sed -i "/^$ptoken:/d" "$table_name"
            echo "Record with primary key '$ptoken' deleted successfully."
            ;;

        2)
            # Delete the value of a specific column
            read -p "Enter the primary key of the record you want to update: " ptoken

            # Get the index of the primary key column from the metadata
            pk_col_index=$(awk -F: '/PK/ {print NR}' ".meta$table_name")

            # Ensure the primary key exists
            if ! awk -F: -v pk="$ptoken" -v idx="$pk_col_index" '{if ($idx == pk) print $0}' "$table_name" | grep -q "$ptoken"; then
                echo "The entered primary key does not exist in the '$table_name' table."
                return
            fi

            # List available columns (skip the primary key)
            total_cols=$(awk -F: 'END{print NR}' ".meta$table_name")
            for ((j = 2; j <= total_cols; j++)); do
                col_name=$(awk -F: 'NR=='$j' {print $1}' ".meta$table_name")
                echo "$((j-1)). $col_name"  # Display adjusted column number
            done

            read -p "Choose the number of the column you want to delete the value from: " col_num
            if ! [[ $col_num =~ ^[0-9]+$ ]] || [ $col_num -lt 1 ] || [ $col_num -gt $((total_cols-1)) ]; then
                echo "Please enter a valid column number."
                return
            fi

            # Get the record using primary key
            record=$(awk -F: -v pk="$ptoken" -v idx="$pk_col_index" '{if ($idx == pk) print $0}' "$table_name")
            # The user selects a column, so we adjust by +1 to match the cut index
            current_value=$(echo "$record" | cut -d: -f"$((col_num+1))")

            # Confirm deletion
            read -p "Are you sure you want to delete the value '$current_value' from column '$col_name'? (y/n): " confirm
            if [[ $confirm != "y" ]]; then
                echo "Operation canceled."
                return
            fi

            # Delete the value by replacing it with an empty string (or another placeholder if necessary)
            new_record=$(echo "$record" | awk -F: -v idx="$((col_num+1))" 'BEGIN{OFS=":"} {$idx=""; print}')
            sed -i "/^$ptoken:/s/.*/$new_record/" "$table_name"
            echo "Value in column '$col_name' deleted successfully."
            ;;

        *)
            echo "Invalid option. Please choose either 1 or 2."
            return
            ;;
    esac
}

function select_tb(){

    read -p "please enter table name: " table_name 
#adding column names into a separate file #may change this to save column names in an array later
    awk -F : '{print $1}' .meta$table_name > .temp_file

    PS3="Please choose a select option: "

    select choice in table column record exit
    do 
    case $choice in 
    "table")
        awk '{ print $1 }' ./$table_name
        continue
        ;;
    "column")
        echo "the columns in this table are: $(cat .temp_file | tr '\n' ' ') " 
        read -p "please enter the column you need to select: " col_name
        if ! grep -Fxq "$col_name" .temp_file
        then 
            echo "column name isnt valid. please enter a valid name"
            break
        else
            field_no=$(awk -v col_name="$col_name" '{if ($1 == col_name) {print NR}} ' .temp_file)
            cut -d : -f $field_no "$table_name"
            continue
        fi
        ;;

    "record")
        echo "the columns in this table are: $(cat .temp_file | tr '\n' ' ') "
        read -p "please enter the column to select by: " col_name
        if ! grep -Fxq "$col_name" .temp_file
        then 
            echo "column name isnt valid. please enter a valid name"
            break
        else 
            field_no=$(awk -v col_name="$col_name" '{if ($1 == col_name) {print NR}} ' .temp_file)
            read -p "please enter a value to select the record by: " val_name
            select_result=$(awk -v field_no="$field_no" -v val_name="$val_name" '
                {
            if ($field_no == val_name) {
                print $0
                found = 1
            }
        }
        END {
            if (!found) {
                print "Selected value not found in the column."
            }
        }
            ' "$table_name")

            echo "$select_result"

        fi 

        continue
        ;;

    "exit")
        break
        ;;
    esac
    done

}

function listtb(){
if [[ $(ls) ]] #checks if  our current directory is empty , since we'r already connected to database so ls can list current content  
then
echo "Tables in current database are :"
ls
else 
echo "Selected Database is still empty , Add a few tables"
fi 
}

function droptb (){
    read -p "Enter table's name to drop : " droppedtb
    if [[ -f $droppedtb ]] #if this table is a file then delete it 
    then 
        rm $droppedtb
        rm ".meta$droppedtb"
        echo "Table $droppedtb is dropped successfully"
    else 
        echo "Table doesn't exist"
    fi 
}


function connectdb(){

    read -p "Enter database name to connect to : " selecteddb
if [[ -e $selecteddb ]] 
then
cd $selecteddb
dbname=$(pwd) #set dbname to current directory Ensures $dbname reflects the current directory after connecting to a database.

echo "Connected to $selecteddb successfully"
PS3="Please select an option to work with $selecteddb database : "
select choice in "Create Table" "List Tables" "Drop Table" "Insert into Table" "Select From Table" "Delete From Table" "Update Table" "Exit"
  do 
  case $choice in 
  "Create Table") createtable
  ;;
  "List Tables") listtb
    continue
  ;;
  "Drop Table") droptb
  ;;
  "Insert into Table") insertdata
  ;;
 "Select From Table") select_tb
  ;;
  "Delete From Table" ) deletetb
  ;;
 "Update Table") updatedb
  ;;
  "Exit") 
        cd ..
        db_menu
  ;;
  *) echo "Please enter a valid option."
  ;;
  esac 
  done
else 
echo "Please enter a valid /existing database name" 
fi

}
function dropdb(){
 read -p "Enter database name to drop : " droppeddb
if [[ -e $droppeddb ]]
then 
rm -r $droppeddb 
echo "Database is dropped successfully"
else 
echo "Enter a valid/existing database name to drop"
fi   

}


function db_menu(){
    PS3="Please select an option regarding databases : "
    select choice in "Create a Database" "List Databases" "Connect to a Database" "Drop a Database" "Exit"
    do 
    case $choice in 
    "Create a Database") createdb
    ;;
    "List Databases") listdb
    ;;
    "Connect to a Database") connectdb
    ;;
    "Drop a Database") dropdb
    ;;
    "Exit") exit
    ;;
    *) echo "Please enter a valid option."
    ;;
    esac 
    done
}

echo "Welcome to DBMS :)"
db_menu
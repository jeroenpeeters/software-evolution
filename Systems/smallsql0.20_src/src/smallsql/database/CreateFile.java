/*
 * Created on 30.11.2008
 */
package smallsql.database;

import java.io.File;
import java.io.RandomAccessFile;
import java.sql.SQLException;

import smallsql.database.language.Language;

/**
 * @author Volker Berlin
 */
public class CreateFile extends TransactionStep{

    private final File file;
    private final SSConnection con;
    private final Database database;


    CreateFile(File file, RandomAccessFile raFile,SSConnection con, Database database){
        super(raFile);
        this.file = file;
        this.con = con;
        this.database = database;
    }


    /**
     * {@inheritDoc}
     */
    long commit(){
        raFile = null;
        return -1;
    }


    /**
     * {@inheritDoc}
     */
    void rollback() throws SQLException{
        RandomAccessFile currentRaFile = raFile;
        if(raFile == null){
            return;
        }
        raFile = null;
        try{
            currentRaFile.close();
        }catch(Throwable ex){
            //ignore it
        }
        con.rollbackFile(currentRaFile);
        if(!file.delete()){
            file.deleteOnExit();
            throw SmallSQLException.create(Language.FILE_CANT_DELETE, file.getPath());
        }
        
        String name = file.getName();
        name = name.substring(0, name.lastIndexOf('.'));
        database.removeTableView(name);
    }

}

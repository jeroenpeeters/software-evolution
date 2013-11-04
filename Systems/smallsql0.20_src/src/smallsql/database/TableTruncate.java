/*
 * Created on 09.12.2007
 */
package smallsql.database;

import java.io.RandomAccessFile;



/**
 * @author Volker Berlin
 */
public class TableTruncate extends StorePage{

    TableTruncate(byte[] page, int pageSize, RandomAccessFile raFile, long fileOffset){
        super(page, pageSize, raFile, fileOffset);
        // TODO Auto-generated constructor stub
    }

}

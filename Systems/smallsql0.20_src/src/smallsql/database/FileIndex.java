/* =============================================================
 * SmallSQL : a free Java DBMS library for the Java(tm) platform
 * =============================================================
 *
 * (C) Copyright 2004-2007, by Volker Berlin.
 *
 * Project Info:  http://www.smallsql.de/
 *
 * This library is free software; you can redistribute it and/or modify it 
 * under the terms of the GNU Lesser General Public License as published by 
 * the Free Software Foundation; either version 2.1 of the License, or 
 * (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful, but 
 * WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY 
 * or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public 
 * License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, 
 * USA.  
 *
 * [Java is a trademark or registered trademark of Sun Microsystems, Inc. 
 * in the United States and other countries.]
 *
 * ---------------
 * FileIndex.java
 * ---------------
 * Author: Volker Berlin
 * 
 * Created on 24.09.2006
 */
package smallsql.database;

import java.io.*;


/**
 * @author Volker Berlin
 */
class FileIndex extends Index {

static public void main(String args[]) throws Exception{
    File file = File.createTempFile("test", "idx");
    RandomAccessFile raFile = Utils.openRaFile(file);
    FileIndex index = new FileIndex(false, raFile);
    Expressions expressions = new Expressions();
    ExpressionValue value = new ExpressionValue();
    expressions.add(value);
    value.set( "150", SQLTokenizer.VARCHAR);
    index.addValues(1, expressions);
    value.set( "15", SQLTokenizer.VARCHAR);
    index.addValues(2, expressions);
    print(index,expressions);
    index.save();
    index.close();
    
    System.out.println("Idx size:"+file.length());
    raFile = Utils.openRaFile(file);
    index = FileIndex.load(raFile);
    print(index,expressions);
}

static void print(Index index, Expressions expressions){
    IndexScrollStatus scroll = index.createScrollStatus(expressions);
    long l;
    while((l= scroll.getRowOffset(true)) >=0){
        System.out.println(l);
    }
    System.out.println("============================");
}

    
    private final RandomAccessFile raFile;
    
    
    FileIndex( boolean unique, RandomAccessFile raFile ) {
        this(new FileIndexNode( unique, (char)-1, raFile), raFile);
    }
    
    
    FileIndex( FileIndexNode root, RandomAccessFile raFile ) {
        super(root);
        this.raFile = raFile;
    }
    
    
    static FileIndex load( RandomAccessFile raFile ) throws Exception{
        boolean unique = raFile.readBoolean();
        FileIndexNode root = FileIndexNode.loadRootNode( unique, raFile, raFile.getFilePointer() );
        return new FileIndex( root, raFile );
    }
    
    
    void save() throws Exception{
        raFile.writeBoolean( rootPage.getUnique() );
        ((FileIndexNode)rootPage).save();
    }
    
    
    void close() throws IOException{
        raFile.close();
    }

}

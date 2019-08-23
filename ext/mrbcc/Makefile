CC = gcc
TARGET = libparse.so
PARSE = parse

all: libparse.so

libparse.so: $(PARSE).c
	$(CC) -c -fPIC -o $(PARSE).o $(PARSE).c
	$(CC) -shared -o $(TARGET) $(PARSE).o

$(PARSE).c: lemon
	../../vendor/lemon/lemon -p ./$(PARSE).y

lemon:
	cd ../../vendor/lemon ; $(MAKE) all

clean:
	cd ../../vendor/lemon ; $(MAKE) clean
	rm -f $(PARSE).c $(TARGET) $(PARSE).h $(PARSE).out $(PARSE).o
